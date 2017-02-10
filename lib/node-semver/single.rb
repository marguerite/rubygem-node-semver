module Semver
	class Single
		def initialize(version)
			@version = version
		end

		def valid
			v = clean
			if v =~ /^[0-9]+\.[0-9]+\.[0-9]+(-)?((alpha|beta|rc)(\.)?[0-9]+)?(\+.*)?$/
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

			else
				raise Semver::InvalidReleaseType
			end
		end

		def clean
			@version.strip.gsub(/^(v|=v)?/,'')
		end

		def major
			v = clean
			/^([0-9]+)\..*$/.match(v)[1].to_i
		end

		def minor
			v = clean
			/^[0-9]+\.([0-9]+)\..*$/.match(v)[1].to_i
		end

		def patch
			v = clean
			/^[0-9]+\.[0-9]+\.([0-9]+)(.*)?$/.match(v)[1].to_i
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
