module DispatchHelper

  def initial_activities
    {
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
  end

  def parse_payload!(payload)
    return if payload.context.raw_payload.dig('issue').nil?

    @context = payload.context
    @paper = Paper.where('review_issue_id = ? OR meta_review_issue_id = ?', @context.issue_id, @context.issue_id).first
    return false unless @paper
    @paper.activities = initial_activities if @paper.activities.empty?

    if payload.edited?
      process_edit
    elsif payload.labeled?
      process_labeling
    elsif payload.commented?
      process_comment
    else
      @paper.save
    end
  end

  def process_edit
    updated_at = @context.raw_payload.dig('issue', 'updated_at')
    @paper.activities['issues']['last_edits'] ||= {}
    @paper.activities['issues']['last_edits'][@context.sender] = updated_at

    @paper.percent_complete = @paper.fraction_check_boxes_complete
    @paper.last_activity = updated_at
    @paper.save
  end

  # Parse the labels and update paper with the new labels.
  def process_labeling
    new_labels = Hash.new
    @context.issue_labels.each do |label|
      new_labels.merge!(label['name'] => label['color'])
    end

    @paper.labels = new_labels
    @paper.save
  end

  def process_comment
    if @context.issue_title.match(/^\[PRE REVIEW\]:/)
      return if @context.issue_id != @paper.meta_review_issue_id
      kind = 'pre-review'
    else
      return if @context.issue_id != @paper.review_issue_id
      kind = 'review'
    end

    @paper.activities['issues']['last_comments'] ||= {}
    @paper.activities['issues']['last_comments'][@context.sender] = @context.comment_created_at
    @paper.last_activity = @context.comment_created_at
    @paper.activities['issues']['comments'].unshift(
      'author' => @context.sender,
      'comment' => @context.comment_body,
      'commented_at' => @context.comment_created_at,
      'comment_url' => @context.comment_url,
      'kind' => kind
    )

    if @paper.activities['issues']['commenters'][kind].has_key?(@context.sender)
      @paper.activities['issues']['commenters'][kind][@context.sender] += 1
    else
      @paper.activities['issues']['commenters'][kind].merge!(@context.sender => 1)
    end

    # Only keep the last 5 comments
    @paper.activities['issues']['comments'] = @paper.activities['issues']['comments'].take(5)

    @paper.last_activity = @context.comment_created_at
    @paper.save
  end
end
