require 'spec_helper'

describe Semver do
  it "has a version number" do
    expect(Semver::VERSION).not_to be nil
  end

  it "can handle hyphen ranges" do
	  expect(Semver::Ranges.new("1.2.3 - 3.3.4").parse).to eq([">=1.2.3","<=3.3.4"])
  end

  it "can handle hyphen ranges (partial version as the first version)" do
	  expect(Semver::Ranges.new("1.2 - 2.3.4").parse).to eq([">=1.2.0","<=2.3.4"])
  end

  it "can handle hyphen ranges (partial version as the second version)" do
	  expect(Semver::Ranges.new("1.2.3 - 3.3").parse).to eq([">=1.2.3","<3.4.0"])
  end

  it "can handle hyphen ranges (partial version as the second version)" do
	  expect(Semver::Ranges.new("1.2.3 - 2").parse).to eq([">=1.2.3","<3.0.0"])
  end

  it "can handle x ranges 1.x" do
	  expect(Semver::Ranges.new("1.x").parse).to eq([">=1.0.0","<2.0.0"])
  end

  it "can handle x ranges 1.2.x" do
	  expect(Semver::Ranges.new("1.2.x").parse).to eq([">=1.2.0","<1.3.0"])
  end

  it "can handle x ranges 1" do
	  expect(Semver::Ranges.new("1").parse).to eq([">=1.0.0","<2.0.0"])
  end

  it "can handle x ranges 1.2" do
	  expect(Semver::Ranges.new("1.2").parse).to eq([">=1.2.0","<1.3.0"])
  end

  it "can handle * ranges: *" do
	  expect(Semver::Ranges.new("*").parse).to eq([">=0.0.0"])
  end

  it "can handle * ranges: 1.2.*" do
	  expect(Semver::Ranges.new("1.2.*").parse).to eq([">=1.2.0","<1.3.0"])
  end

  it "can handle empty ranges" do
	  expect(Semver::Ranges.new("").parse).to eq([">=0.0.0"])
  end

  it "can handle tilde ranges" do
	  expect(Semver::Ranges.new("~2.2.3").parse).to eq([">=2.2.3","<2.3.0"])
  end

  it "can handle tilde ranges" do
	  expect(Semver::Ranges.new("~1.2").parse).to eq([">=1.2.0","<1.3.0"])
  end

  it "can handle tilde ranges" do
	  expect(Semver::Ranges.new("~1").parse).to eq([">=1.0.0","<2.0.0"])
  end

  it "can handle tilde ranges" do
	  expect(Semver::Ranges.new("~0.2.3").parse).to eq([">=0.2.3","<0.3.0"])
  end

  it "can handle tilde ranges" do
	  expect(Semver::Ranges.new("~0.2").parse).to eq([">=0.2.0","<0.3.0"])
  end

  it "can handle tilde ranges" do
	  expect(Semver::Ranges.new("~0").parse).to eq([">=0.0.0","<1.0.0"])
  end

  it "can handle tilde ranges" do
	  expect(Semver::Ranges.new("~1.2.3-beta.2").parse).to eq([">=1.2.3-beta.2","<1.3.0"])
  end

  it "can handle caret ranges" do
	  expect(Semver::Ranges.new("^1.2.3").parse).to eq([">=1.2.3","<2.0.0"])
  end

  it "can handle caret ranges" do
	  expect(Semver::Ranges.new("^0.2.3").parse).to eq([">=0.2.3","<0.3.0"])
  end

  it "can handle caret ranges" do
	  expect(Semver::Ranges.new("^0.0.3").parse).to eq([">=0.0.3","<0.0.4"])
  end

  it "can handle caret ranges" do
	  expect(Semver::Ranges.new("^1.2.3-beta.2").parse).to eq([">=1.2.3-beta.2","<2.0.0"])
  end

  it "can handle caret ranges" do
	  expect(Semver::Ranges.new("^0.0.3-beta").parse).to eq([">=0.0.3-beta","<0.0.4"])
  end

  it "can handle caret ranges" do
	  expect(Semver::Ranges.new("^1.2.x").parse).to eq([">=1.2.0","<2.0.0"])
  end

  it "can handle caret ranges" do
	  expect(Semver::Ranges.new("^0.0.x").parse).to eq([">=0.0.0","<0.1.0"])
  end

  it "can handle caret ranges" do
	  expect(Semver::Ranges.new("^0.0").parse).to eq([">=0.0.0","<0.1.0"])
  end

  it "can handle caret ranges" do
	  expect(Semver::Ranges.new("^1.x").parse).to eq([">=1.0.0","<2.0.0"])
  end

  it "can handle caret ranges" do
	  expect(Semver::Ranges.new("^0.x").parse).to eq([">=0.0.0","<1.0.0"])
  end

  it "can handle pipe ranges" do
	  expect(Semver::Ranges.new("1.2.7 || >=1.2.9 <2.0.0").parse).to eq(["1.2.7",[">=1.2.9","<2.0.0"]])
  end

  it "can handle whitespace ranges" do
	  expect(Semver::Ranges.new(">=1.2.9 <2.0.0").parse).to eq([">=1.2.9","<2.0.0"])
  end

  it "can call validRange function" do
	  expect(Semver.validRange("^1.2.x")).to eq([">=1.2.0","<2.0.0"])
  end

end
