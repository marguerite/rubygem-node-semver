module NodeSemver
  # parse a standalone single version like '1.0.0-beta.1'
  class Instance
    include Comparable
    attr_reader :version, :major, :minor, :patch, :prerelease

    def initialize(version)
      # There is small but real possibility that upstream
      # doesn't have version number. It's smaller problem
      # to have something than crash
      v = '0.0.0'
      if !version.nil?
         v = tidy(version)
      end
      tmp = normal_parse(v)
      tmp = dirty_parse(v) if tmp.nil?
      @version, @major, @minor, @patch, *@prerelease = tmp
      @prerelease = nil if @prerelease.include?(nil)
    end

    def valid
      version
    end

    def main_ver
      version.sub(/-.*$/, '')
    end

    def <=>(other)
      if main_ver == other.main_ver &&
         [prerelease, other.prerelease].include?(nil)
        compare_prerelease(self, other)
      else
        version <=> other.version
      end
    end

    def -(other)
      return if self == other
      if prerelease.nil? && other.prerelease.nil?
        main_diff(self, other)
      else
        return 'prerelease' if main.call.nil?
        'pre' + main_diff(self, other)
      end
    end

    def inc(reltype, preid)
      raise 'Invalid reltype' unless RELTYPES.include?(reltype)
      if reltype == 'prerelease'
        unless @prerelease.nil?
          return @version.sub(/\.(\d+)$/) do
                   ".#{Regexp.last_match(1).to_i + 1}"
                 end
        end
        reltype = 'prepatch'
      end
      if reltype.start_with?('pre')
        indicator = 1
        reltype.sub!('pre', '')
      end
      version = inc_version_by_type(@version, reltype)
      return version if indicator.nil?
      version + '-' + preid + '.0'
    end

    private

    def inc_version_by_type(version, type)
      str = '(\d+)\.'
      level = %w[major minor patch].index(type)
      regex = (str * (level + 1)).sub!(/\\\.$/, '')
      version.sub!(/^#{regex}/) do
        repl = ''
        level.times { |i| repl << Regexp.last_match(i + 1) + '.' }
        repl << (send(type).to_i + 1).to_s
        repl
      end.sub(/-.*$/, '')
    end

    def tidy(version)
      # remove the surrounding spaces, and the leading 'v' or '=v'
      version = Regexp.last_match(1) if version.strip =~ /^=?v?(\d+.*)$/
      # remove the whitespace between comparator and the actual version
      version = version.gsub(/(.*)\s+(\d+.*)/) { Regexp.last_match(1) + Regexp.last_match(2) }
      # eg '2.0.0-alpha', have pre type but no pre num
      version += '.0' if version =~ /\d+\.\d+-?[A-Za-z]+$/
      version
    end

    def normal_parse(version)
      r = /^(\d+)\.(\d+)\.(\d+)(-?([A-Za-z]+)\.?(\d+))?(\+.*)?$/
      return unless version =~ r
      m = version.match(r)
      # the build metadata is not a capturing group
      [m[0].sub(/\+.*$/, ''), m[1], m[2], m[3], m[5], m[6]]
    end

    # these are actually not valid, but has landed in npm registry
    # due to unknown reasons
    def dirty_parse(version)
      # dateformat '0.9.0-1.2.3', strip meaningless '-1.2.3'
      version.sub!(/-.*$/, '') if version =~ /\d+-\d+\./
      # readable-stream '1.0.26-1', is actually '1.0.27-prerelease.1'
      if version =~ /(\d+)-(\d+)$/
        patch_num = Regexp.last_match(1)
        pre_num = Regexp.last_match(2)
        version.sub!(/#{patch_num}-.*$/) do
          "#{patch_num.to_i + 1}-prerelease.#{pre_num}"
        end
      end
      # glob '2.0.7-bindist-testing', is actually '2.0.7-prerelease.0'
      version.sub!(/-.*$/, '-prerelease.0') if version =~ /\d+-[A-Za-z]+-[A-Za-z]+$/
      # validate-npm-package-license '1.0.0-prerelease-1', is actually '1.0.0-prerelease.1'
      if version =~ /\d+(-)?[A-Za-z]+-\d+/
        version.sub!(/([A-Za-z]+)-(\d+)/) do
          "#{Regexp.last_match(1)}.#{Regexp.last_match(2)}"
        end
      end
      # babylon '7.0.0-beta.0-ranges'
      if version =~ /[A-Za-z]+\.\d+(-?[A-Za-z]+)$/
        version.sub!(Regexp.last_match(1), '')
      end
      normal_parse(version)
    end

    def compare_prerelease(v1, v2)
      return 0 if v1.prerelease == v2.prerelease
      v1.prerelease.nil? ? 1 : -1
    end

    def main_diff(v1, v2)
      if v1.major != v2.major
        'major'
      elsif v1.minor != v2.minor
        'minor'
      elsif v1.patch != v2.patch
        'patch'
      end
    end
  end
end
