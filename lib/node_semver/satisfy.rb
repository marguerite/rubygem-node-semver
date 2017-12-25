module NodeSemver
  class Satisfaction
    def initialize(version, range)
      @version = NodeSemver.valid(version)
      @range = NodeSemver::Range.new(range).valid_range
    end

    %i[satisfy gtr ltr].each do |m|
      define_method m do
        if @range[0].instance_of?(Array)
          @range.map! do |r|
            send(m.to_s + '?', @version, r)
          end.include?(true)
        else
          send(m.to_s + '?', @version, @range)
        end
      end
    end

    private

    def satisfy?(version, range)
      range.map! do |r|
        fit?(version, r)
      end.include?(true)
    end

    def fit?(version, range, reverse=false)
      comparator, other = split_comparator(range)
      comparator = opposite(comparator) if reverse
      comparator = '==' if comparator.eql?('=')
      NodeSemver.cmp(version, comparator, other)
    end

    def split_comparator(version)
      [version.gsub(/^(.*?)\d+.*$/, '\1'),
       version.gsub(/^.*?(\d+.*)$/, '\1')]
    end

    def outside?(version, range)
      out = 0
      range.each do |r|
        sym = fit?(version, r, true)
        next unless sym
	comparator, other = split_comparator(r)
        out = if comparator =~ />/
                -1
              elsif comparator =~ /</
                1
	      else
                # the equal case
                NodeSemver::Instance.new(version) <=> NodeSemver::Instance.new(other)
              end
      end
      out
    end

    def opposite(comparator)
      hash = { '>' => '<=', '>=' => '<', '<' => '>=', '<=' => '>', '=' => '!=' }
      hash[comparator]
    end

    def gtr?(version, range)
      outside?(version, range) > 0
    end

    def ltr?(version, range)
      outside?(version, range) < 0
    end
  end
end
