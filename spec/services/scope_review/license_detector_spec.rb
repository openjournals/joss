require "rails_helper"
require "tmpdir"

RSpec.describe ScopeReview::LicenseDetector do
  MIT_TEXT = <<~TXT.freeze
    MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files...
  TXT

  def detect(files, host_spdx: nil)
    Dir.mktmpdir do |dir|
      files.each { |rel, content| File.write(File.join(dir, rel), content) }
      return described_class.detect(dir, files.keys, host_spdx: host_spdx)
    end
  end

  it "prefers the host-reported SPDX id" do
    result = detect({ "LICENSE" => "whatever" }, host_spdx: "Apache-2.0")
    expect(result[:spdx_id]).to eq("Apache-2.0")
    expect(result[:osi_approved]).to be(true)
  end

  it "identifies MIT from the license file on non-GitHub hosts" do
    result = detect({ "LICENSE" => MIT_TEXT })
    expect(result[:spdx_id]).to eq("MIT")
    expect(result[:osi_approved]).to be(true)
  end

  it "marks known non-OSI licenses as false" do
    result = detect({ "LICENSE" => "x" }, host_spdx: "CC0-1.0")
    expect(result[:osi_approved]).to be(false)
  end

  it "is unknown (nil) for an unidentifiable license file" do
    result = detect({ "LICENSE" => "Custom Institute License v7. All rights whatever." })
    expect(result[:spdx_id]).to be_nil
    expect(result[:osi_approved]).to be_nil
  end

  it "is a definite failure when there is no license file at all" do
    result = detect({ "README.md" => "hi" })
    expect(result[:osi_approved]).to be(false)
  end
end
