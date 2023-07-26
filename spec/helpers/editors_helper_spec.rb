describe EditorsHelper do
  before do
    @editor = create(:editor, max_assignments: 5, availability_comment: nil)
    @assignment_by_editor = { @editor.id => 4 }
    @paused_by_editor = { @editor.id => 1 }
  end

  describe "display_availability" do
    it "displays icon with current availability" do
      @editor.max_assignments = 3
      expect(display_availability(@editor)).to include("3")

      @editor.max_assignments = 4
      expect(display_availability(@editor)).to include("4")

      @editor.max_assignments = 5
      expect(display_availability(@editor)).to include("5")
    end

    it "displays availability comment if present" do
      expect(display_availability(@editor)).to include("5")
      expect(display_availability(@editor)).to_not include("*")

      @editor.availability_comment = "OOO until january"
      expect(display_availability(@editor)).to include("5*")
      expect(display_availability(@editor)).to include("OOO until january")
    end
  end

  describe "in_progress_for_editor" do
    it "returns assigned papers" do
      @paused_by_editor = { @editor.id => 0 }
      expect(in_progress_for_editor(@editor)).to eq("4")
    end

    it "returns assigned + paused papers if present" do
      expect(in_progress_for_editor(@editor)).to include("3")
      expect(in_progress_for_editor(@editor)).to include("(+ 1)")
    end
  end

  describe "in_progress_no_paused_for_editor" do
    it "returns count of assigned not paused papers" do
      expect(in_progress_no_paused_for_editor(@editor)).to eq(3)

      expect(in_progress_no_paused_for_editor(create(:editor))).to eq(0)
    end
  end

  describe "availability_class" do
    before do
      @editor = create(:editor)
      @assignment_by_editor = {}
      @paused_by_editor = {}
    end

    it "should be none" do
      @editor.max_assignments = -2
      expect(availability_class(@editor)).to eq("availability-none")

      @editor.max_assignments = 0
      expect(availability_class(@editor)).to eq("availability-none")
    end

    it "should be somewhat" do
      @editor.max_assignments = 1
      expect(availability_class(@editor)).to eq("availability-somewhat")
    end

    it "should be empty if available" do
      @editor.max_assignments = 2
      expect(availability_class(@editor)).to eq("")

      @editor.max_assignments = 15
      expect(availability_class(@editor)).to eq("")
    end

    it "takes current assignments into account" do
      @assignment_by_editor = { @editor.id => 4 }
      @paused_by_editor = { @editor.id => 1 }

      @editor.max_assignments = 3
      expect(availability_class(@editor)).to eq("availability-none")

      @editor.max_assignments = 4
      expect(availability_class(@editor)).to eq("availability-somewhat")

      @editor.max_assignments = 5
      expect(availability_class(@editor)).to eq("")
    end
  end
end
