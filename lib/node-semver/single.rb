module Semver
	class Single
		def initialize(version)
			@version = version
		end

		def valid
			v = clean
			if v =~ /^\d+\.\d+\.\d+(-)?([A-Za-z]+(\.)?\d+)?(\+.*)?$/
				if [major.class,minor.class,patch.class].include? Bignum
					raise Semver::InvalidVersion.new "One of the major/minor/patch numbers goes beyond Fixnum!"
				elsif v.size > 256
					raise Semver::InvalidVersion.new "Version longer than 256 characters!"
				else
					v.gsub(/\+.*$/,'') # the build metadata is not a capturing group.
				end
			else
				nil
			end
		end

		def inc(releasetype)
			if VALIDRELEASETYPES.include?(releasetype)
				version = valid
				mainversion = version.gsub(/(\d+)((-|[A-Za-z]+).*$)/) { "#{$1}" }
				pre = prerelease_number
				pre_t = prerelease_type
				case releasetype
				when "major"
					mainversion.gsub(/^(\d+)/) { "#{major + 1}" }
				when "premajor"
					mainversion.gsub(/^(\d+)/) { "#{major + 1}" } + "-alpha.0"
				when "minor"
					mainversion.gsub(/^(\d+)\.(\d+)/) { "#{$1}.#{minor + 1}" }
				when "preminor"
					mainversion.gsub(/^(\d+)\.(\d+)/) { "#{$1}.#{minor + 1}" } + "-alpha.0"
				when "patch"
					mainversion.gsub(/^(\d+)\.(\d+)\.(\d+)/) { "#{$1}.#{$2}.#{patch + 1}" }
				when "prepatch"
					mainversion.gsub(/^(\d+)\.(\d+)\.(\d+)/) { "#{$1}.#{$2}.#{patch + 1}" } + "-alpha.0"
				else # prerelease
					if pre.nil?
						mainversion.gsub(/^(\d+)\.(\d+)\.(\d+)/) { "#{$1}.#{$2}.#{patch + 1}" } + "-alpha.0"
					else
						version.gsub(/(\d+)(-)?([A-Za-z]+(\.)?)(\d+)/) { "#{$1}#{$2}#{pre_t}#{$4}#{pre + 1}"}
					end	
				end
			else
				raise Semver::InvalidReleaseType
			end
		end

		def clean
			@version.strip.gsub(/^(v|=v)?/,'')
		end

		def major
			v = clean
			/^(\d+)\..*$/.match(v)[1].to_i
		end

		def minor
			v = clean
			/^\d+\.(\d+)\..*$/.match(v)[1].to_i
		end

		def patch
			v = clean
			/^\d+\.\d+\.(\d+)(.*)?$/.match(v)[1].to_i
		end

		def prerelease
			v = clean
			if v =~ /\d+(-)?[A-Za-z]+(\.)?\d+(.*)?$/
				/\d+(-)?([A-Za-z]+(\.)?\d+)(.*)?$/.match(v)[2]
			else
				nil
			end
		end

		def prerelease_type
			str = prerelease
			if prerelease.nil?
				nil
			else
				/([A-Za-z]+)/.match(str)[1]
			end
		end

		def prerelease_number
			str = prerelease
			if prerelease.nil?
				nil
			else
				/[A-Za-z](\.)?(\d+)/.match(str)[2].to_i
			end
		end

		# comparision

		def gt(v1,v2)
		end

		def gte(v1,v2)
		end

		def lt(v1,v2)

		end

		def lte(v1,v2)
		end

		def eq(v1,v2)
		end

		def neq(v1,v2)
		end

		def cmp(v1, comparator, v2)
		end

		def compare(v1,v2)
		end

		def rcompare(v1,v2)

		end

		def diff(v1,v2)
		end

		private

	end
end
