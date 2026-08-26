module ScopeReview
  # Detects whether the repository ships an automated test suite (the Gate 3a
  # baseline), what framework it appears to use, whether the only "tests" are
  # notebooks, and whether CI actually runs the suite. A paper-PDF build
  # workflow is NOT a test suite.
  class TestSignals
    TEST_PATH_RE = %r{(\A|/)(tests?|spec|testthat|inst/tests)(/|\z)}i
    TEST_BASENAME_RE = /\A(test_.+\.(py|r|jl|c|cpp)|.+_test\.(py|go|rb|c|cc|cpp|js|ts)|.+\.test\.(js|ts|jsx|tsx|mjs)|.+_spec\.rb|runtests\.jl|testthat\.r)\z/i

    CI_TEST_COMMAND_RE = /\b(pytest|tox\b|nox\b|unittest|testthat|devtools::(test|check)|R CMD check|rcmdcheck|npm (run )?test|yarn test|pnpm test|jest|vitest|mocha\b|rspec|rake( test| spec)|go test|cargo test|ctest|make (test|check)|julia .*(test|Pkg\.test)|Pkg\.test|python -m pytest|hatch (run )?test|dotnet test|mvn (test|verify)|gradle(w)? (test|check))\b/i

    CI_FILES = [
      %r{\A\.github/workflows/.+\.ya?ml\z},
      %r{\A\.gitlab-ci\.ya?ml\z},
      %r{\A\.travis\.ya?ml\z},
      %r{\Aazure-pipelines\.ya?ml\z},
      %r{\A\.circleci/config\.ya?ml\z},
      %r{\Aappveyor\.ya?ml\z},
    ].freeze

    def initialize(dir, relative_paths)
      @dir = dir
      @paths = relative_paths
    end

    def to_h
      {
        has_automated: has_automated?,
        kind: kind,
        notebooks_only: notebooks_only?,
        ci_present: ci_files.any?,
        ci_runs_tests: ci_runs_tests?,
        test_file_count: test_files.length,
      }
    end

    def test_files
      @test_files ||= @paths.select do |p|
        (p.match?(TEST_PATH_RE) || File.basename(p).match?(TEST_BASENAME_RE)) &&
          !p.match?(%r{(\A|/)(\.github|docs?|node_modules|vendor)/})
      end
    end

    def real_test_files
      @real_test_files ||= test_files.reject { |p| File.extname(p).casecmp?(".ipynb") }
                                     .select { |p| code_file?(p) }
    end

    def has_automated?
      kind != "none"
    end

    def notebooks_only?
      real_test_files.empty? && test_files.any? { |p| File.extname(p).casecmp?(".ipynb") }
    end

    def kind
      @kind ||=
        if @paths.any? { |p| p.match?(%r{\Atests?/testthat(/|\z)}i) } || contains?("DESCRIPTION", /testthat/)
          "testthat"
        elsif runtests_jl?
          "julia-test"
        elsif pytest?
          "pytest"
        elsif @paths.any? { |p| p.match?(/_spec\.rb\z/) }
          "rspec"
        elsif js_test_script?
          "js-test"
        elsif @paths.any? { |p| p.match?(/_test\.go\z/) }
          "go-test"
        elsif @paths.include?("Cargo.toml") && real_test_files.any? { |p| p.end_with?(".rs") }
          "cargo-test"
        elsif contains?("CMakeLists.txt", /enable_testing|add_test/i)
          "ctest"
        elsif contains?("Makefile", /^(test|check):/)
          "make-test"
        elsif real_test_files.any? { |p| p.end_with?(".py") }
          "unittest"
        elsif real_test_files.any?
          "unclassified"
        else
          "none"
        end
    end

    def ci_files
      @ci_files ||= @paths.select { |p| CI_FILES.any? { |re| p.match?(re) } }
    end

    def ci_runs_tests?
      ci_files.any? { |p| read(p)&.match?(CI_TEST_COMMAND_RE) }
    end

    private

    def pytest?
      return true if @paths.include?("pytest.ini") || @paths.include?("conftest.py")
      return true if contains?("pyproject.toml", /\[tool\.pytest|pytest/) && python_test_files?
      return true if contains?("setup.cfg", /\[tool:pytest\]/)
      return true if contains?("tox.ini", /pytest/)

      python_test_files? && @paths.any? { |p| p.match?(%r{(\A|/)tests?/}i) && p.end_with?(".py") }
    end

    def python_test_files?
      real_test_files.any? { |p| p.end_with?(".py") }
    end

    def runtests_jl?
      @paths.any? { |p| p.match?(%r{\Atest/runtests\.jl\z}i) }
    end

    def js_test_script?
      pkg = read("package.json")
      return false unless pkg

      script = JSON.parse(pkg).dig("scripts", "test").to_s
      script.present? && !script.include?("no test specified")
    rescue JSON::ParserError
      false
    end

    def code_file?(path)
      lang = LanguageStats::LANGUAGES[File.extname(path).downcase]
      lang.present? && !LanguageStats.data_path?(path)
    end

    def contains?(filename, regex)
      read(filename)&.match?(regex) || false
    end

    def read(rel)
      return nil unless @paths.include?(rel)

      path = File.join(@dir, rel)
      return nil unless File.file?(path) && File.size(path) < 512 * 1024

      File.read(path, encoding: "UTF-8").scrub
    rescue Errno::ENOENT, Errno::EACCES
      nil
    end
  end
end
