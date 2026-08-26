require "rails_helper"
require "tmpdir"

RSpec.describe ScopeReview::PaperSignals do
  let(:paper_md) do
    <<~PAPER
      ---
      title: 'ExampleTool: doing science'
      authors:
        - name: Ada Lovelace
          affiliation: 1
        - name: Grace Hopper
          affiliation: 2
      bibliography: refs.bib
      ---

      # Statement of need

      Words words words.

      # State of the field

      More words.

      # Software design

      Design.

      # Research impact statement

      Impact.

      # AI usage disclosure

      None.
    PAPER
  end

  let(:bib) do
    <<~BIB
      @article{lovelace2025,
        author = {Lovelace, Ada and Turing, Alan},
        title = {Applications of ExampleTool},
        year = {2025}
      }
      @misc{other,
        author = {Hopper, Grace},
        title = {Something else}
      }
    BIB
  end

  def with_repo(files)
    Dir.mktmpdir do |dir|
      files.each do |rel, content|
        path = File.join(dir, rel)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, content)
      end
      return yield(described_class.new(dir, files.keys))
    end
  end

  it "locates the paper, counts words, and finds all five sections" do
    with_repo("paper/paper.md" => paper_md, "paper/refs.bib" => bib) do |signals|
      h = signals.to_h
      expect(h[:found]).to be(true)
      expect(h[:path]).to eq("paper/paper.md")
      expect(h[:word_count]).to be > 10
      expect(h.values_at(:has_statement_of_need, :has_state_of_field, :has_software_design,
                         :has_research_impact, :has_ai_disclosure)).to all(be(true))
    end
  end

  it "extracts paper authors from the frontmatter" do
    with_repo("paper/paper.md" => paper_md, "paper/refs.bib" => bib) do |signals|
      expect(signals.author_names).to eq(["Ada Lovelace", "Grace Hopper"])
    end
  end

  it "finds the declared bibliography and extracts author names, normalising 'Last, First'" do
    with_repo("paper/paper.md" => paper_md, "paper/refs.bib" => bib) do |signals|
      expect(signals.to_h[:bib_path]).to eq("paper/refs.bib")
      expect(signals.bib_authors).to contain_exactly("Ada Lovelace", "Alan Turing", "Grace Hopper")
    end
  end

  it "reports a missing paper" do
    with_repo("README.md" => "hi") do |signals|
      expect(signals.to_h).to eq({ found: false, path: nil })
    end
  end

  it "flags missing 2026 sections" do
    minimal = "---\ntitle: x\n---\n# Statement of need\nWords.\n"
    with_repo("paper.md" => minimal) do |signals|
      h = signals.to_h
      expect(h[:has_statement_of_need]).to be(true)
      expect(h[:has_research_impact]).to be(false)
      expect(h[:has_ai_disclosure]).to be(false)
    end
  end
end
