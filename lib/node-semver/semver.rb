module Semver

	def valid(v)
		Semver::Single.new(v).valid
	end

	def clean(v)
		if valid(v).nil?
			raise "You can't clean an invalid version"
		else
			Semver::Single.new(v).clean
		end
	end

	def major(v)
		if valid(v).nil?
			raise "You can't get major number for invalid version!"
		else
			Semver::Single.new(v).major
		end
	end

	def minor(v)
		if valid(v).nil?
			raise "You can't get minor number for invalid version!"
		else
			Semver::Single.new(v).minor
		end
	end

	def patch(v)
		if valid(v).nil?
			raise "You can't get patch number for invalid version!"
		else
			Semver::Single.new(v).patch
		end
	end

	def prerelease(v)
		if valid(v).nil?
			raise "You can't get prerelease string for invalid version!"
		else
			Semver::Single.new(v).prerelease
		end
	end

	def prerelease_type(v)
		if valid(v).nil?
			raise "You can't get prerelease type for invalid version!"
		else
			Semver::Single.new(v).prerelease_type
		end
	end

	def prerelease_number(v)
		if valid(v).nil?
			raise "You can't get prerelease number for invalid version!"
		else
			Semver::Single.new(v).prerelease_number
		end
	end

	def inc(v,releasetype)
		if valid(v).nil?
			raise "You can't increase version for invalid version!"
		else
			Semver::Single.new(v).inc(releasetype)
		end
	end

	def validRange(range)
		range_arr = Semver::Range.new(range).parse
		if range_arr.instance_of?(Array)
			return range_arr
		else
			return nil
		end
	end
	module_function :valid,:clean,:major,:minor,:patch,:prerelease,:prerelease_type,:prerelease_number,:inc
	module_function :validRange
end
