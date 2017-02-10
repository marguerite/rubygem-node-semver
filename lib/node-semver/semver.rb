module Semver

	def valid(version)

	end

	def validRange(range)
		range_arr = Semver::Ranges.new(range).parse
		if range_arr.instance_of?(Array)
			return range_arr
		else
			return nil
		end
	end
	module_function :validRange :valid
end

