require 'rails_helper'

describe TocController, type: :controller do
  describe "#sanitize_page_param" do
    it "clamps an array page param to an integer" do
      controller.params[:page] = ["99999999"]
      controller.send(:sanitize_page_param)
      expect(controller.params[:page]).to eq(200)
    end

    it "clamps a huge page number to the maximum" do
      controller.params[:page] = "99999999"
      controller.send(:sanitize_page_param)
      expect(controller.params[:page]).to eq(200)
    end

    it "preserves a valid page number" do
      controller.params[:page] = "5"
      controller.send(:sanitize_page_param)
      expect(controller.params[:page]).to eq(5)
    end
  end
end
