module ScopeReview
  # Templated author-facing drafts for deterministic gate failures, modelled
  # on the notes the EiCs actually post: plain thank-you, no decorative
  # praise, lead with the least-arguable computed fact, and — for
  # too-young repositories — make explicit that serving out the six months
  # alone will not make the submission eligible.
  #
  # The EiC edits and sends these by hand — nothing here is ever auto-posted.
  class DraftNote
    SCOPE_LINK = "https://joss.readthedocs.io/en/latest/submitting.html#scope-and-significance".freeze
    OTHER_VENUES_LINK = "https://joss.readthedocs.io/en/latest/submitting.html#other-venues-for-reviewing-and-publishing-software-packages".freeze

    SIX_MONTHS_CAVEAT =
      "**Important:** Meeting the six-month development history requirement alone is not " \
      "sufficient for JOSS publication. We will also be looking for clear evidence of " \
      "demonstrated impact (such as publications using the software, external adoption beyond " \
      "your research group, or documented research enabled by your tool). Simply keeping a " \
      "repository public for six months without evidence of use or community adoption will " \
      "not make a submission eligible.".freeze

    GATE_PARAGRAPHS = {
      license: ->(note) { "JOSS requires software to be released under an OSI-approved open-source license. #{note}" },
      gate1_development_history: lambda { |note|
        "> Projects developed privately are not eligible until there is a public record of open " \
        "development: at least six months of public history prior to submission, with evidence " \
        "of releases, public issues and pull requests.\n\n#{note}"
      },
      gate3a_open_development:
        ->(note) { "#{note} We would encourage you to resubmit once the repository includes an automated test suite that allows a reviewer to verify the software's functional claims." },
      gate3b_collaborative_effort:
        ->(note) { "JOSS submissions are expected to show development shaped by a broader community context. #{note}" },
      gate4_iterative_development:
        ->(note) { "JOSS looks for evidence of iterative development over time rather than a single burst of commits. #{note}" },
    }.freeze

    def self.for_clean_fail(paper, gate_results)
      failed = Array(gate_results[:hard_fails]).map(&:to_sym)
      notes = gate_results[:gate_notes] || {}

      paragraphs = failed.filter_map do |gate|
        template = GATE_PARAGRAPHS[gate]
        template&.call(notes[gate].to_s.strip)
      end
      paragraphs << SIX_MONTHS_CAVEAT if failed.include?(:gate1_development_history)

      <<~NOTE.strip
        Thanks for your submission to JOSS.

        I'm sorry to say that this submission does not meet the current [scope and significance](#{SCOPE_LINK}) requirements for review by JOSS.

        #{paragraphs.join("\n\n")}

        Please see #{OTHER_VENUES_LINK} for other suggestions for how you might receive credit for your work.
      NOTE
    end
  end
end
