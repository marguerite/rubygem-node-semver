module Semver
	class Comparison
		def initialize(v1,v2)
			@v1 = Semver.valid(v1)
			@v2 = Semver.valid(v2)
		end

		def gt
			compareVer > 0 ? true : false
		end

		def gte
			compareVer >= 0 ? true : false
		end

		def lt
			compareVer < 0 ? true : false
		end

		def lte
			compareVer <= 0 ? true : false
		end

		def eq
			compareVer == 0 ? true : false
		end

		def neq
			compareVer != 0 ? true : false
		end

		def cmp(comparator)
			case comparator
			when ">"
				gt
			when ">="
				gte
			when "<"
				lt
			when "<="
				lte
			when "=","=="
				eq
			when "!="
				neq
			else
				raise InvalidComparator.new comparator
			end
		end

		def compare
			if gt
				1
			elsif lt
				-1
			else
				0
			end
		end

		def diff
			if eq
				nil
			else
				if Semver.pre_t(@v1).nil? && Semver.pre_t(@v2).nil?
					if Semver.major(@v1) != Semver.major(@v2)
						"major"
					elsif Semver.minor(@v1) != Semver.minor(@v2)
						"minor"
					else
						Semver.patch(@v1) != Semver.patch(@v2) ? "patch" : nil
					end
				else
					if Semver.major(@v1) != Semver.major(@v2)
						"premajor"
					elsif Semver.minor(@v1) != Semver.minor(@v2)
						"preminor"
					else
						if Semver.patch(@v1) != Semver.patch(@v2)
							"prepatch"
						else
							if comparePre == 0
								nil
							else
								"prerelease"
							end
						end
					end
				end
			end
		end

		private

		def compareVer
			compareMain == 0 ? comparePre : compareMain
		end

		def compareNum(n1,n2)
			if n1 > n2
				1
			elsif n1 < n2
				-1
			else
				nil # nil here for the return statement in compareMain, the easiest way
			end
		end

		def compareMain
			r = compareNum(Semver.major(@v1),Semver.major(@v2)) || compareNum(Semver.minor(@v1),Semver.minor(@v2)) || compareNum(Semver.patch(@v1),Semver.patch(@v2))

			return r.nil? ? 0 : r
		end

		def comparePre
			if comparePretype > 0
				1
			elsif comparePretype < 0
				-1
			else
				if Semver.pre_n(@v1).nil? && Semver.pre_n(@v2).nil?
					0
				else
					r = compareNum(Semver.pre_n(@v1),Semver.pre_n(@v2))
					r.nil? ? 0 : r
				end
			end
		end

		def comparePretype
			prev1 = Semver.pre_t(@v1)
			prev2 = Semver.pre_t(@v2)

			if prev1.nil? && prev2.nil?
				# both have no Pretype, equal
				0
			elsif prev1.nil? && ! prev2.nil?
				# prev1 doesn't have prerelease while prev2 has
				# we only compare prerelease when main are the same
				# released version is greater than prerelease one
				1
			elsif prev2.nil? && ! prev2.nil?
				-1
			else
				# Alphabetically, a < b < r
				if prev1[0] > prev2[0]
					1
				elsif prev1[0] < prev2[0]
					-1
				else
					0
				end
			end
		end
	end
end
