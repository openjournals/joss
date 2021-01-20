module DispatchHelper

  def handle(payload)
    parser = PayloadParser.new(payload)

    # Exit early if the paper doesn't exist
    return false unless parser.paper

    parser.parse_payload!
  end

  class PayloadParser
    attr_accessor :payload
    attr_accessor :issue_number
    attr_accessor :action

    def initialize(payload)
      @payload = payload
      @issue_number = payload['issue']['number']
      @action = payload['action']

      initialize_activities if (paper && paper.activities.empty?)
    end

    def paper
      @paper ||= Paper.where('review_issue_id = ? OR meta_review_issue_id = ?',
                              issue_number,
                              issue_number).first
    end

    def sender
      payload['sender']['login']
    end

    def title
      payload['issue']['title']
    end

    def labels
      payload['issue']['labels']
    end

    def comment_body
      payload['comment']['body']
    end

    def commented_at
      payload['comment']['created_at']
    end

    def comment_url
      payload['comment']['html_url']
    end

    def pre_review?
      title.match(/^\[PRE REVIEW\]:/)
    end

    # Has the review issue just been opened? If so, don't do anything.
    def opened?
      action == 'opened' || action == 'reopened'
    end

    # Has the review issue just been closed? If so, don't do anything.
    def closed?
      action == 'closed'
    end

    def commented?
      action == 'created'
    end

    def edited?
      action == 'edited'
    end

    def locked?
      action == 'locked'
    end

    def unlocked?
      action == 'unlocked'
    end

    def pinned?
      action == 'pinned' || action == "unpinned"
    end

    def assigned?
      action == 'assigned' || action == 'unassigned'
    end

    def labeled?
      action == 'labeled' || action == 'unlabeled'
    end

    def initialize_activities
      activities = {
        'issues' => {
          'commenters' => {
            'pre-review' => {},
            'review' => {}
          },
          'comments' => [],
          'last_edits' => {},
          'last_comments' => {}
        }
      }

      paper.activities = activities
      paper.save
    end

    # Parse the incoming payload and do something with it...
    def parse_payload!
      return if assigned?
      return if opened?
      return if closed?
      return if locked?
      return if pinned?
      return if unlocked?

      if edited?
        if issues.has_key?('last_edits')
          issues['last_edits'][sender] = payload['issue']['updated_at']
        else
          issues['last_edits'] = {}
          issues['last_edits'][sender] = payload['issue']['updated_at']
        end
        paper.last_activity = payload['issue']['updated_at']
        paper.save and return
      end

      # Parse the labels and update papers with the new labels.
      if labeled?
        new_labels = Hash.new
        labels.each do |label|
          new_labels.merge!(label['name'] => label['color'])
        end

        paper.labels = new_labels
        paper.save and return
      end

      # New addition to keep track of the last comments by each 
      # person on the thread.
      if commented?
        if issues.has_key?('last_comments')
          issues['last_comments'][sender] = payload['issue']['updated_at']
        else
          issues['last_comments'] = {}
          issues['last_comments'][sender] = payload['issue']['updated_at']
        end
        paper.last_activity = payload['issue']['updated_at']
      end

      if pre_review?
        kind = 'pre-review'
        return if issue_number != paper.meta_review_issue_id
      else
        kind = 'review'
        return if issue_number != paper.review_issue_id
      end

      issues['comments'].unshift(
        'author' => sender,
        'comment' => comment_body,
        'commented_at' => commented_at,
        'comment_url' => comment_url,
        'kind' => kind
      )

      # Something has gone wrong if this isn't the case...
      if issues['commenters'][kind].has_key?(sender)
        issues['commenters'][kind][sender] += 1
      else
        issues['commenters'][kind].merge!(sender => 1)
      end

      # Only keep the last 5 comments
      issues['comments'] = issues['comments'].take(5)

      paper.last_activity = commented_at
      paper.save
    end

    # For each author,
    def update_comment_counts
      paper.activities
    end

    def issues
      paper.activities['issues']
    end

    def update_comments(comment)

    end
  end
end
