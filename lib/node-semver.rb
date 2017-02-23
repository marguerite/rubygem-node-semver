require 'node-semver/compare.rb'
require 'node-semver/exception.rb'
require 'node-semver/range.rb'
require 'node-semver/satisfy.rb'
require 'node-semver/single.rb'
require 'node-semver/version.rb'

module Semver

	def self.valid(v)
		Semver::Single.new(v).valid
	end

	def self.clean(v)
		if valid(v).nil?
			raise "You can't clean an invalid version"
		else
			Semver::Single.new(v).clean
		end
	end

	def self.major(v)
		if valid(v).nil?
			raise "You can't get major number for invalid version!"
		else
			Semver::Single.new(v).major
		end
	end

	def self.minor(v)
		if valid(v).nil?
			raise "You can't get minor number for invalid version!"
		else
			Semver::Single.new(v).minor
		end
	end

	def self.patch(v)
		if valid(v).nil?
			raise "You can't get patch number for invalid version!"
		else
			Semver::Single.new(v).patch
		end
	end

	def self.pre(v)
		if valid(v).nil?
			raise "You can't get prerelease string for invalid version!"
		else
			Semver::Single.new(v).pre
		end
	end

	def self.pre_t(v)
		if valid(v).nil?
			raise "You can't get prerelease type for invalid version!"
		else
			Semver::Single.new(v).pre_t
		end
	end

	def self.pre_n(v)
		if valid(v).nil?
			raise "You can't get prerelease number for invalid version!"
		else
			Semver::Single.new(v).pre_n
		end
	end

	def self.inc(v,releasetype)
		if valid(v).nil?
			raise "You can't increase version for invalid version!"
		else
			Semver::Single.new(v).inc(releasetype)
		end
	end

	def self.gt(v1,v2)
		Semver::Comparison.new(v1,v2).gt
	end

	def self.gte(v1,v2)
		Semver::Comparison.new(v1,v2).gte
	end

	def self.lt(v1,v2)
		Semver::Comparison.new(v1,v2).lt
	end

	def self.lte(v1,v2)
		Semver::Comparison.new(v1,v2).lte
	end

	def self.eq(v1,v2)
		Semver::Comparison.new(v1,v2).eq
	end

	def self.neq(v1,v2)
		Semver::Comparison.new(v1,v2).neq
	end

	def self.cmp(v1,comparator,v2)
		Semver::Comparison.new(v1,v2).cmp(comparator)
	end

	def self.compare(v1,v2)
		Semver::Comparison.new(v1,v2).compare
	end

	def self.rcompare(v1,v2)
		Semver::Comparison.new(v2,v1).compare
	end

	def self.diff(v1,v2)
		Semver::Comparison.new(v1,v2).diff
	end

	def self.sort(list)
		while true do
			flag = false
			for i in 1..(list.size - 1) do
				if Semver::Comparison.new(list[i - 1],list[i]).gt
					tmp = list[i].dup
					list[i] = list[i - 1].dup
					list[i - 1] = tmp
					flag = true
				end
			end
			break if flag == false
		end

		return list
	end

	def self.rsort(list)
		while true do
			flag = false
			for i in 1..(list.size - 1) do
				if Semver::Comparison.new(list[i - 1],list[i]).lt
					tmp = list[i]
					list[i] = list[i - 1]
					list[i - 1] = tmp
					flag = true
				end
			end
			break if flag == false
		end

		return list
	end

	def self.validRange(range)
		Semver::Range.new(range).validRange
	end

	def self.satisfies(version,range)
		Semver::Satisfaction.new(version,range).satisfy
	end

	def self.maxSatisfying(versions,range)
		satisfied_versions = []
		versions.each do |v|
			if Semver.satisfies(v,range)
				satisfied_versions << v
			end
		end
		satisfied_versions.empty? ? nil : satisfied_versions.sort[-1]
	end

	def self.gtr(version,range)
		Semver::Satisfaction.new(version,range).gtr
	end

	def self.ltr(version,range)
		Semver::Satisfaction.new(version,range).ltr
	end

	def self.outside(version,range,hilo=nil)
		Semver::Satisfaction.new(version,range).outside(hilo)
	end
end
