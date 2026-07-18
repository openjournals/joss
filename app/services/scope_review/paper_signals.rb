require "yaml"

module ScopeReview
  # Locates and inspects the submitted paper (paper.md, the required name): word
  # count, the five required 2026 sections, author names from the YAML
  # frontmatter, and author names appearing in the bibliography (the
  # self-citation overlap signal for Gate 2).
  class PaperSignals
    SECTION_CHECKS = {
      has_statement_of_need: /#+\s*Statement of need/i,
      has_state_of_field: /#+\s*State of the field/i,
      has_software_design: /#+\s*Software design/i,
      has_research_impact: /#+\s*Research impact( statement)?/i,
      has_ai_disclosure: /#+\s*AI (usage|use) disclosure/i,
    }.freeze

    MAX_PAPER_BYTES = 2 * 1024 * 1024

    attr_reader :path

    def initialize(dir, relative_paths)
      @dir = dir
      @paths = relative_paths
      @path = locate_paper
      @content = @path ? read(@path) : nil
    end

    def found?
      @content.present?
    end

    def content
      @content
    end

    def paper_dir
      return nil unless @path

      dir = File.dirname(@path)
      dir == "." ? nil : dir
    end

    def to_h
      return { found: false, path: nil } unless found?

      {
        found: true,
        path: @path,
        word_count: word_count,
        **section_flags,
        authors: author_names,
        bib_path: bib_path,
        bib_found: bib_content.present?,
        bib_authors: bib_authors,
      }
    end

    def word_count
      @content.split.size
    end

    def section_flags
      SECTION_CHECKS.transform_values { |re| @content.match?(re) }
    end

    # Author names from the paper.md YAML frontmatter.
    def author_names
      names = Array(frontmatter["authors"]).filter_map do |a|
        a.is_a?(Hash) ? (a["name"] || [a["given-names"], a["surname"]].compact.join(" ").presence) : a.to_s.presence
      end
      names.map(&:strip).reject(&:empty?)
    end

    def bib_path
      @bib_path ||= begin
        declared = frontmatter["bibliography"].to_s.strip
        candidates = []
        if declared.present?
          candidates << (paper_dir ? File.join(paper_dir, declared) : declared)
          candidates << declared
        end
        candidates << (paper_dir ? File.join(paper_dir, "paper.bib") : "paper.bib")
        candidates << "paper.bib"
        candidates.uniq.find { |c| @paths.include?(c) }
      end
    end

    def bib_content
      @bib_content ||= bib_path ? read(bib_path) : nil
    end

    # Every name in the bibliography's author fields — matched later against
    # the paper's authors to flag self-citation-only impact evidence.
    def bib_authors
      return [] if bib_content.blank?

      bib_content.scan(/^\s*author\s*=\s*[{"]([^}"]+)[}"]/i).flatten.flat_map do |field|
        field.split(/\s+and\s+/i).map do |name|
          name = name.strip.delete("{}")
          name.include?(",") ? name.split(",").reverse.map(&:strip).join(" ") : name
        end
      end.reject(&:empty?).uniq
    end

    private

    # The paper must be named paper.md — that's the submission requirement.
    # Prefer conventional locations, then the shallowest paper.md anywhere in
    # the tree. Anything else (paper.tex, main.md, …) is "not found" and the
    # author needs to fix it.
    def locate_paper
      %w[paper/paper.md paper.md].find { |p| @paths.include?(p) } ||
        @paths.select { |p| p.end_with?("/paper.md") }.min_by { |p| p.count("/") }
    end

    def frontmatter
      @frontmatter ||= begin
        m = @content.to_s.match(/\A---\s*\n(.*?)\n(?:---|\.\.\.)\s*(\n|\z)/m)
        m ? YAML.safe_load(m[1], permitted_classes: [Date, Time], aliases: true) || {} : {}
      rescue Psych::Exception
        {}
      end
    end

    def read(rel)
      path = File.join(@dir, rel)
      return nil unless File.file?(path) && File.size(path) <= MAX_PAPER_BYTES

      File.read(path, encoding: "UTF-8").scrub
    rescue Errno::ENOENT, Errno::EACCES
      nil
    end
  end
end
