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

	def pre(v)
		if valid(v).nil?
			raise "You can't get prerelease string for invalid version!"
		else
			Semver::Single.new(v).pre
		end
	end

	def pre_t(v)
		if valid(v).nil?
			raise "You can't get prerelease type for invalid version!"
		else
			Semver::Single.new(v).pre_t
		end
	end

	def pre_n(v)
		if valid(v).nil?
			raise "You can't get prerelease number for invalid version!"
		else
			Semver::Single.new(v).pre_n
		end
	end

	def inc(v,releasetype)
		if valid(v).nil?
			raise "You can't increase version for invalid version!"
		else
			Semver::Single.new(v).inc(releasetype)
		end
	end

	def gt(v1,v2)
		Semver::Comparison.new(v1,v2).gt
	end

	def gte(v1,v2)
		Semver::Comparison.new(v1,v2).gte
	end

	def lt(v1,v2)
		Semver::Comparison.new(v1,v2).lt
	end

	def lte(v1,v2)
		Semver::Comparison.new(v1,v2).lte
	end

	def eq(v1,v2)
		Semver::Comparison.new(v1,v2).eq
	end

	def neq(v1,v2)
		Semver::Comparison.new(v1,v2).neq
	end

	def cmp(v1,comparator,v2)
		Semver::Comparison.new(v1,v2).cmp(comparator)
	end

	def compare(v1,v2)
		Semver::Comparison.new(v1,v2).compare
	end

	def rcompare(v1,v2)
		Semver::Comparison.new(v2,v1).compare
	end

	def diff(v1,v2)
		Semver::Comparison.new(v1,v2).diff
	end

	def sort(list)
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

	def rsort(list)
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

	def validRange(range)
		Semver::Range.new(range).validRange
	end

	def satisfies(version,range)
		Semver::Satisfaction.new(version,range).satisfy
	end

	def maxSatisfying(versions,range)
		satisfied_versions = []
		versions.each do |v|
			if Semver.satisfies(v,range)
				satisfied_versions << v
			end
		end
		satisfied_versions.empty? ? nil : satisfied_versions.sort[-1]
	end

	def gtr(version,range)
		Semver::Satisfaction.new(version,range).gtr
	end

	def ltr(version,range)
		Semver::Satisfaction.new(version,range).ltr
	end

	def outside(version,range,hilo=nil)
		Semver::Satisfaction.new(version,range).outside(hilo)
	end

	module_function :valid,:clean,:major,:minor,:patch,:pre,:pre_t,:pre_n,:inc
	module_function :gt,:gte,:lt,:lte,:eq,:neq,:cmp,:compare,:rcompare,:diff,:sort,:rsort
	module_function :validRange,:satisfies,:maxSatisfying,:gtr,:ltr,:outside
end
