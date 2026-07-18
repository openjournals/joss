require "rails_helper"
require "tmpdir"

RSpec.describe ScopeReview::TestSignals do
  def signals_for(paths, files: {})
    Dir.mktmpdir do |dir|
      files.each do |rel, content|
        path = File.join(dir, rel)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, content)
      end
      return described_class.new(dir, paths + files.keys).to_h
    end
  end

  it "detects pytest suites" do
    result = signals_for(%w[src/pkg.py tests/test_core.py tests/test_io.py conftest.py])
    expect(result[:has_automated]).to be(true)
    expect(result[:kind]).to eq("pytest")
  end

  it "detects testthat suites" do
    result = signals_for(%w[R/model.R tests/testthat/test-model.R tests/testthat.R])
    expect(result[:kind]).to eq("testthat")
  end

  it "detects julia test suites" do
    result = signals_for(%w[src/Pkg.jl test/runtests.jl])
    expect(result[:kind]).to eq("julia-test")
  end

  it "reports no tests for an untested repo" do
    result = signals_for(%w[src/main.py README.md docs/index.md])
    expect(result[:has_automated]).to be(false)
    expect(result[:kind]).to eq("none")
  end

  it "flags notebooks-only test evidence" do
    result = signals_for(%w[src/main.py tests/validation.ipynb tests/demo.ipynb])
    expect(result[:has_automated]).to be(false)
    expect(result[:notebooks_only]).to be(true)
  end

  it "sees CI that runs tests" do
    result = signals_for(%w[src/x.py tests/test_x.py],
                         files: { ".github/workflows/ci.yml" => "jobs:\n  test:\n    steps:\n      - run: pytest -v\n" })
    expect(result[:ci_runs_tests]).to be(true)
  end

  it "does not count a paper-PDF build workflow as a test run" do
    result = signals_for(%w[src/x.py tests/test_x.py],
                         files: { ".github/workflows/draft-pdf.yml" => "jobs:\n  paper:\n    steps:\n      - uses: openjournals/openjournals-draft-action@master\n" })
    expect(result[:ci_present]).to be(true)
    expect(result[:ci_runs_tests]).to be(false)
  end

  it "reads the package.json test script" do
    result = signals_for(%w[src/index.js test/index.test.js],
                         files: { "package.json" => '{"scripts": {"test": "vitest run"}}' })
    expect(result[:kind]).to eq("js-test")
  end

  it "ignores a placeholder npm test script" do
    result = signals_for(%w[src/index.js],
                         files: { "package.json" => %({"scripts": {"test": "echo \\"Error: no test specified\\" && exit 1"}}) })
    expect(result[:has_automated]).to be(false)
  end
end
