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
			raise "You shouldn't get major number for invalid version!"
		else
			Semver::Single.new(v).major
		end
	end

	def minor(v)
		if valid(v).nil?
			raise "You shouldn't get minor number for invalid version!"
		else
			Semver::Single.new(v).minor
		end
	end

	def patch(v)
		if valid(v).nil?
			raise "You shouldn't get patch number for invalid version!"
		else
			Semver::Single.new(v).patch
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
	module_function :valid,:clean,:major,:minor,:patch
	module_function :validRange
end
