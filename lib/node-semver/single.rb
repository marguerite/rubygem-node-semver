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
				# special treatment for dateformat "0.9.0-1.2.3" which is actually not valid,
				# but has been included in npm registry
				if v =~ /\d+-\d+/
					v.gsub(/-.*$/,'') # strip the meaningless "-1.2.3"
				else
					nil
				end
			end
		end

		def inc(releasetype)
			if VALIDRELEASETYPES.include?(releasetype)
				version = valid
				mainversion = version.gsub(/(\d+)((-|[A-Za-z]+).*$)/) { "#{$1}" }
				pre_num = pre_n
				pre_type = pre_t
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
					if pre_num.nil?
						mainversion.gsub(/^(\d+)\.(\d+)\.(\d+)/) { "#{$1}.#{$2}.#{patch + 1}" } + "-alpha.0"
					else
						version.gsub(/(\d+)(-)?([A-Za-z]+(\.)?)(\d+)/) { "#{$1}#{$2}#{pre_type}#{$4}#{pre_num + 1}" }
					end	
				end
			else
				raise Semver::InvalidReleaseType
			end
		end

		def clean
			# remove the surrounding whitespaces and tabs, and the leading "v"/"v="
			v = @version.strip.gsub(/^(v|=v)?/,'')
			# remove the whitespace between comparator and the actual version
			v.gsub(/\s+(\d+.*)/) { "#{$1}" }
			# like "2.0.0-alpha", have prerelease type while have no prerelease number
			# fill the number with 0
			if v =~ /\d+(-)?[A-Za-z]+$/
				v += ".0"
			end

			return v
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

		def pre
			v = clean
			if v =~ /\d+(-)?[A-Za-z]+(\.)?\d+(.*)?$/
				/\d+(-)?([A-Za-z]+(\.)?\d+)(.*)?$/.match(v)[2]
			else
				nil
			end
		end

		def pre_t
			str = pre
			if pre.nil?
				nil
			else
				/([A-Za-z]+)/.match(str)[1]
			end
		end

		def pre_n
			str = pre
			if pre.nil?
				nil
			else
				/[A-Za-z](\.)?(\d+)/.match(str)[2].to_i
			end
		end
	end
end
