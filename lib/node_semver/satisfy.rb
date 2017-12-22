module NodeSemver
  class Satisfaction
    def initialize(version, range)
      @version = NodeSemver.valid(version)
      @range = NodeSemver::Range.new(range).valid_range
    end

    %i[satisfy gtr ltr outside].each do |m|
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

    def fit?(version, range)
      comparator, other = split_comparator(range)
      comparator = '==' if comparator.eql?('=')
      NodeSemver.cmp(version, comparator, other)
    end

    def split_comparator(version)
      [version.gsub(/^(.*?)\d+.*$/, '\1'),
       version.gsub(/^.*?(\d+.*)$/, '\1')]
    end

    def outside?(version, range)
      out = 0
      range.each_with_index do |r, i|
        comparator, other = split_comparator(r)
        comparator = opposite(comparator)
        sym = NodeSemver.cmp(version, comparator, other)
        next unless sym
        out = if i.zero?
                -1
              elsif i == 1
                1
              end
      end
      out
    end

    def opposite(comparator)
      hash = { '>' => '<=', '>=' => '<', '<' => '>=', '<=' => '>' }
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
