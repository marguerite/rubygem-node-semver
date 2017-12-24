module NodeSemver
  # parse a standalone single version like '1.0.0-beta.1'
  class Instance
    include Comparable
    attr_reader :version, :major, :minor, :patch, :prerelease

    def initialize(version)
      v = tidy(version) || '0.0.0'
      tmp = normal_parse(v)
      tmp = dirty_parse(v) if tmp.nil?
      @version, @major, @minor, @patch, *@prerelease = tmp
      @prerelease = nil if @prerelease.include?(nil)
    end

    def valid
      raise 'Not numeric' unless numeric?
      raise 'Version overflows' if overflow?
      raise 'Negative version' if negative?
      raise 'Version too long' if version.size > 256
      version
    end

    def <=>(other)
      main = compare_main(other)
      return main unless main.zero?
      compare_prerelease(other)
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

    def compare_main(other)
      spaceship(major, other.major) ||
      spaceship(minor, other.minor) ||
      spaceship(patch, other.patch) ||
      0
    end

    def spaceship(v1, v2)
      stat = v1.to_i <=> v2.to_i
      stat.zero? ? false : stat
    end

    def compare_prerelease(other)
      return 0 if prerelease.nil? && other.prerelease.nil?
      # ['alpha', '3']
      return spaceship(prerelease[0][0],other.prerelease[0][0]) || prerelease[1] <=> other.prerelease[1] unless prerelease.nil? || other.prerelease.nil?
      prerelease.nil? ? -1 : 1
    end

    def comparable?(other)
      return if !compare_main(other).zero? && !prerelease.nil? && !other.prerelease.nil?
      0
    end

    def overflow?
      max = 4611686018427387903
      major.to_i > max ||
      minor.to_i > max ||
      patch.to_i > max ||
      !prerelease.nil? && prerelease[1].to_i > max ||
      false
    end

    def negative?
      major.to_i < 0 ||
      minor.to_i < 0 ||
      patch.to_i < 0 ||
      !prerelease.nil? && prerelease[1].to_i < 0 ||
      false
    end

    def numeric?
      stat = major =~ /\d+/ &&
             minor =~ /\d+/ &&
             patch =~ /\d+/
      stat += prerelease[1] =~ /\d+/ unless prerelease.nil?
    end

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
      return if version.nil?
      # remove the surrounding spaces, and the leading 'v' or '=v'
      version = Regexp.last_match(1) if version.strip =~ /^=?v?(\d+.*)$/
      # remove the whitespace between comparator and the actual version
      version = version.gsub(/(.*)\s+(\d+.*)/) { Regexp.last_match(1) + Regexp.last_match(2) }
      # eg '2.0.0-alpha', have pre type but no pre num
      version += '.0' if version =~ /\d+\.\d+-?[A-Za-z]+$/
      version
    end

    def normal_parse(version)
      r = /^(.*?)\.(.*?)\.(.*?)(-?([A-Za-z]+)\.?(.*?))?(\+.*)?$/
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
