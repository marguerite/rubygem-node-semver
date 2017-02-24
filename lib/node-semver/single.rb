module Semver
  class Single
    def initialize(version)
      @version = version
    end

    def valid
      v = clean
      if v =~ /^\d+\.\d+\.\d+(-)?([A-Za-z]+(\.)?\d+)?(\+.*)?$/
        if [major.class, minor.class, patch.class].include? Integer
          raise Semver::InvalidVersion, 'One of the major/minor/patch numbers goes beyond Fixnum!'
        elsif v.size > 256
          raise Semver::InvalidVersion, 'Version longer than 256 characters!'
        else
          v.gsub(/\+.*$/, '') # the build metadata is not a capturing group.
        end
      elsif v =~ /\d+-\d+\./
        # special treatments: those are actually not valid, but has been included
        #                     in npm registry because of historic reasons
        # dateformat "0.9.0-1.2.3"
        v.gsub(/-.*$/, '') # strip the meaningless "-1.2.3"
      # readable-stream "1.0.26-1", which is actually "1.0.27-alpha.1"
      elsif v =~ /\d+-\d+$/
        regex = /(\d+)-.*$/.match(v)
        bump = (regex[1].to_i + 1).to_s
        prerelease = v.gsub(/^.*-/, '')
        v.gsub(/(#{regex[1]})(\.\d+)?-.*/) { "#{bump}#{Regexp.last_match(2)}-alpha.#{prerelease}" }
      # glob "2.0.7-bindist-testing", which is actually "2.0.7-alpha.1"
      elsif v =~ /\d+-([A-Za-z]|-)+$/
        v.gsub(/-.*$/, '-alpha.1')
      # validate-npm-package-license "1.0.0-prerelease-1", which is actually "1.0.0-prerelease.1"
      elsif v =~ /\d+(-)?[A-Za-z]+-\d+/
        v.gsub(/([A-Za-z]+)-(\d+)/) { "#{Regexp.last_match(1)}.#{Regexp.last_match(2)}" }
      # babylon "7.0.0-beta.0-ranges"
      elsif v =~ /\d+(-)?[A-Za-z]+\.\d+(-)?[A-Za-z]+/
        v.gsub(/\.1$/, '').gsub(/(-)?[A-Za-z]+$/, '')
      end
    end

    def inc(releasetype)
      raise Semver::InvalidReleaseType unless VALIDRELEASETYPES.include?(releasetype)
      version = valid
      mainversion = version.gsub(/(\d+)((-|[A-Za-z]+).*$)/) { Regexp.last_match(1).to_s }
      pre_num = pre_n
      pre_type = pre_t
      case releasetype
      when 'major'
        mainversion.gsub(/^(\d+)/) { (major + 1).to_s }
      when 'premajor'
        mainversion.gsub(/^(\d+)/) { (major + 1).to_s } + '-alpha.1'
      when 'minor'
        mainversion.gsub(/^(\d+)\.(\d+)/) { "#{Regexp.last_match(1)}.#{minor + 1}" }
      when 'preminor'
        mainversion.gsub(/^(\d+)\.(\d+)/) { "#{Regexp.last_match(1)}.#{minor + 1}" } + '-alpha.1'
      when 'patch'
        mainversion.gsub(/^(\d+)\.(\d+)\.(\d+)/) { "#{Regexp.last_match(1)}.#{Regexp.last_match(2)}.#{patch + 1}" }
      when 'prepatch'
        mainversion.gsub(/^(\d+)\.(\d+)\.(\d+)/) { "#{Regexp.last_match(1)}.#{Regexp.last_match(2)}.#{patch + 1}" } + '-alpha.1'
      else # prerelease
        if pre_num.nil?
          mainversion.gsub(/^(\d+)\.(\d+)\.(\d+)/) { "#{Regexp.last_match(1)}.#{Regexp.last_match(2)}.#{patch + 1}" } + '-alpha.1'
        else
          version.gsub(/(\d+)(-)?([A-Za-z]+(\.)?)(\d+)/) { "#{Regexp.last_match(1)}#{Regexp.last_match(2)}#{pre_type}#{Regexp.last_match(4)}#{pre_num + 1}" }
        end
      end
    end

    def clean
      # remove the surrounding whitespaces and tabs, and the leading "v"/"v="
      v = @version.strip.gsub(/^(v|=v)?/, '')
      # remove the whitespace between comparator and the actual version
      v.gsub(/\s+(\d+.*)/) { Regexp.last_match(1).to_s }
      # like "2.0.0-alpha", have prerelease type while have no prerelease number
      # fill the number with 0
      v += '.1' if v =~ /\d+(-)?[A-Za-z]+$/
      v
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
      end
    end

    def pre_t
      str = pre
      pre.nil? ? nil : /([A-Za-z]+)/.match(str)[1]
    end

    def pre_n
      str = pre
      pre.nil? ? nil : /[A-Za-z](\.)?(\d+)/.match(str)[2].to_i
    end
  end
end
