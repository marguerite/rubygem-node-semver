require 'spec_helper'

describe Semver do
	it "can compare greater" do
		expect(Semver.gt("1.2.3","1.2.2")).to eq(true)
	end

	it "can compare lower" do
		expect(Semver.lt("1.2.3","1.2.4")).to eq(true)
	end

	it "can compare greater and equal" do
		expect(Semver.gte("1.2.3","1.2.4")).to eq(false)
	end

	it "can compare lower and equal" do
		expect(Semver.lte("1.2.3","1.2.0")).to eq(false)
	end

	it "can compare equal" do
		expect(Semver.eq("1.2.3","1.2.3")).to eq(true)
	end

	it "can compare neq" do
		expect(Semver.neq("1.2.3","1.2.3")).to eq(false)
	end

	it "can cmp" do
		expect(Semver.cmp("1.2.3",">","1.2.0")).to eq(true)
	end

	it "can compare" do
		expect(Semver.compare("1.2.3","1.2.3")).to eq(0)
	end
	
	it "can rcompare" do
		expect(Semver.rcompare("1.2.3","1.2.4")).to eq(1)
	end

	it "can diff major" do
		expect(Semver.diff("1.2.3","2.2.3")).to eq("major")
	end

	it "can diff minor" do
		expect(Semver.diff("1.2.3","1.3.3")).to eq("minor")
	end

	it "can diff patch" do
		expect(Semver.diff("1.2.3","1.2.4")).to eq("patch")
	end
end
