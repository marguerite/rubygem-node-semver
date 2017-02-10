require 'spec_helper'

describe Semver do

	it "can valid version" do
		expect(Semver.valid(" =v1.2.65535-alpha.123+build.0")).to eq("1.2.65535-alpha.123")
	end

	it "can clean version" do
		expect(Semver.clean(" =v1.2.3")).to eq("1.2.3")
	end

	it "can get major version" do
		expect(Semver.major("1.2.3")).to eq(1)
	end

	it "can get minor version" do
		expect(Semver.minor("1.2.3")).to eq(2)
	end

	it "can get patch version" do
		expect(Semver.patch("1.2.3")).to eq(3)
	end

end
