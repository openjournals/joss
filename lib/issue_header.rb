# Parses the machine-readable header editorialbot maintains at the top of
# pre-review and review issues, e.g.
#
#   **Reviewers:** <!--reviewers-list-->@alice, @bob<!--end-reviewers-list-->
#
module IssueHeader
  REVIEWERS_MARKER = /<!--reviewers-list-->(.*?)<!--end-reviewers-list-->/m
  EDITOR_MARKER = /<!--editor-->(.*?)<!--end-editor-->/m
  PLACEHOLDERS = %w[pending tbd none].freeze

  # Returns the reviewer handles (each with a leading @) listed in the header,
  # or nil when the body has no reviewers-list markers (legacy issues).
  def self.reviewers(body)
    match = REVIEWERS_MARKER.match(body.to_s)
    return nil unless match

    # GitHub logins are case-insensitive, so "@Alice" and "@alice" are the
    # same reviewer; keep the first spelling seen.
    match[1].split(",").map { |handle| normalize_handle(handle) }.compact.uniq(&:downcase)
  end

  # Returns the editor handle (with a leading @) or nil when absent/pending.
  def self.editor(body)
    match = EDITOR_MARKER.match(body.to_s)
    return nil unless match

    normalize_handle(match[1])
  end

  def self.normalize_handle(handle)
    handle = handle.to_s.strip
    return nil if handle.empty? || PLACEHOLDERS.include?(handle.downcase)
    return nil unless handle.match?(/\A@?[A-Za-z0-9][A-Za-z0-9-]*\z/)

    handle.start_with?("@") ? handle : "@#{handle}"
  end
end
