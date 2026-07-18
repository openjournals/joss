require "find"

module ScopeReview
  # Extension-based replacement for cloc/linguist: walks the working tree and
  # aggregates file and line counts per language, distinguishing code from
  # data formats. Exact blank/comment splitting isn't needed for scope
  # signals — what matters is which languages dominate and how much of the
  # repository is data rather than code.
  class LanguageStats
    # Formats that count as data, not code — used both here (repo-level data
    # fraction) and by GitHistory to classify insertion windows (a 90% window
    # of CSV/notebook churn is not a code dump).
    DATA_EXTENSIONS = %w[
      .csv .tsv .json .jsonl .ndjson .geojson .yaml .yml .xml .ipynb
      .dat .txt .log .out .toml .lock
      .nc .h5 .hdf5 .parquet .feather .pkl .pickle .npy .npz .mat .fits
      .tif .tiff .png .jpg .jpeg .gif .svg .pdf
      .zip .gz .tar .bz2 .xz .7z
    ].to_set.freeze

    LANGUAGES = {
      ".py" => "Python", ".pyx" => "Cython", ".r" => "R", ".rmd" => "R",
      ".jl" => "Julia", ".rb" => "Ruby", ".c" => "C", ".h" => "C",
      ".cpp" => "C++", ".cc" => "C++", ".cxx" => "C++", ".hpp" => "C++",
      ".f" => "Fortran", ".f90" => "Fortran", ".f95" => "Fortran", ".f03" => "Fortran",
      ".java" => "Java", ".js" => "JavaScript", ".mjs" => "JavaScript",
      ".jsx" => "JavaScript", ".ts" => "TypeScript", ".tsx" => "TypeScript",
      ".vue" => "Vue", ".svelte" => "Svelte",
      ".go" => "Go", ".rs" => "Rust", ".swift" => "Swift", ".kt" => "Kotlin",
      ".scala" => "Scala", ".m" => "MATLAB/Objective-C", ".cu" => "CUDA",
      ".sh" => "Shell", ".bash" => "Shell", ".zsh" => "Shell", ".ps1" => "PowerShell",
      ".pl" => "Perl", ".php" => "PHP", ".lua" => "Lua", ".hs" => "Haskell",
      ".html" => "HTML", ".htm" => "HTML", ".css" => "CSS", ".scss" => "CSS",
      ".sql" => "SQL", ".tex" => "TeX", ".md" => "Markdown", ".rst" => "reStructuredText",
      ".ipynb" => "Jupyter Notebook", ".csv" => "CSV", ".tsv" => "CSV",
      ".json" => "JSON", ".geojson" => "JSON", ".jsonl" => "JSON",
      ".yaml" => "YAML", ".yml" => "YAML", ".xml" => "XML", ".toml" => "TOML",
      ".txt" => "Text", ".dat" => "Data", ".log" => "Text",
    }.freeze

    SPECIAL_FILENAMES = {
      "makefile" => "Make", "dockerfile" => "Docker", "cmakelists.txt" => "CMake",
      "rakefile" => "Ruby", "gemfile" => "Ruby", "vagrantfile" => "Ruby",
    }.freeze

    SKIP_DIRS = %w[.git node_modules vendor .venv venv __pycache__ .tox dist build site-packages].to_set.freeze

    # Above this size a file's line count is estimated from bytes; giant data
    # files must never be read line-by-line.
    MAX_COUNTED_BYTES = 5 * 1024 * 1024
    ESTIMATED_BYTES_PER_LINE = 80

    def self.data_path?(path)
      DATA_EXTENSIONS.include?(File.extname(path).downcase)
    end

    attr_reader :languages, :total_lines, :data_lines, :code_lines_by_top_dir,
                :file_count, :relative_paths

    def initialize(dir)
      @dir = dir
      @languages = Hash.new { |h, k| h[k] = { files: 0, lines: 0 } }
      @total_lines = 0
      @data_lines = 0
      @code_lines_by_top_dir = Hash.new(0)
      @file_count = 0
      @relative_paths = []
      walk
    end

    def to_h
      {
        languages: top_languages(15),
        top_languages: top_languages(3).keys,
        file_count: @file_count,
        total_lines: @total_lines,
        data_fraction: @total_lines.positive? ? (@data_lines.to_f / @total_lines).round(3) : 0.0,
      }
    end

    def top_languages(n)
      @languages.sort_by { |_, v| -v[:lines] }.first(n).to_h
    end

    # The top-level directory holding the most code (not data/docs) — used to
    # scope path_scoped_age to where the submitted software actually lives.
    def primary_src_dir
      candidates = @code_lines_by_top_dir.reject do |dir, _|
        dir.match?(/\A(docs?|paper|examples?|notebooks?|data|datasets?|tests?|\.)/i)
      end
      candidates.max_by { |_, lines| lines }&.first
    end

    private

    def walk
      Find.find(@dir) do |path|
        rel = path.delete_prefix(@dir).delete_prefix("/")
        if File.directory?(path)
          Find.prune if SKIP_DIRS.include?(File.basename(path).downcase) && rel != ""
          next
        end
        next if File.symlink?(path)

        @file_count += 1
        @relative_paths << rel
        tally(path, rel)
      end
    end

    def tally(path, rel)
      ext = File.extname(rel).downcase
      language = LANGUAGES[ext] || SPECIAL_FILENAMES[File.basename(rel).downcase]
      lines = line_count(path)

      if language
        @languages[language][:files] += 1
        @languages[language][:lines] += lines
      end
      @total_lines += lines

      # Unrecognised extensions are treated as data: for scope purposes the
      # conservative reading is "not demonstrably code".
      if self.class.data_path?(rel) || language.nil?
        @data_lines += lines
      else
        top_dir = rel.include?("/") ? rel.split("/").first : "(root)"
        @code_lines_by_top_dir[top_dir] += lines
      end
    end

    def line_count(path)
      size = File.size(path)
      return 0 if size.zero?
      return (size / ESTIMATED_BYTES_PER_LINE) + 1 if size > MAX_COUNTED_BYTES

      count = 0
      File.foreach(path) { count += 1 }
      count
    rescue ArgumentError, Errno::EACCES, Errno::EISDIR
      0
    end
  end
end
