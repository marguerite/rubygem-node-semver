module NodeSemver
  class Range
    def initialize(version)
      @version = if version.eql?('*') || version.empty?
                   '>=0.0.0'
                 else
		   version.gsub(/(>|<|=)\s/, '\1')
                 end
    end

    def parse
      if @version =~ /\|\||[^-]\s[^-]/
        multi_range(@version)
      else
        single_range(@version)
      end
    end

    def valid_range
      range = parse
      raise 'Not a range' unless range.instance_of?(Array)
      range
    end

    private

    def multi_range(version)
      version =~ /\|\|/ ? parse_pipe(version) : parse_whitespace(version)
    end

    def single_range(version)
      if version =~ /\s-\s/
        parse_hyphen(version)
      elsif version.start_with?('^')
        parse_caret(version)
      elsif version.start_with?('~')
        parse_tilde(version)
      elsif version =~ /x|X|\*/
        parse_x(version)
      else
        version_completion(version)
      end
    end

    def version_completion(version)
      if version =~ /^(>|<|=)/
        [fillup(version)]
      elsif version.split('.').size < 3
        parse_x(version)
      else
        NodeSemver::Instance.new(version).valid.nil? ? nil : ['=' + version]
      end
    end

    def parse_pipe(version)
      version.split('||').map!(&:strip!).map! do |v|
        NodeSemver::Range.new(v).parse
      end
    end

    def parse_whitespace(version)
      version.split("\s").map! do |v|
        NodeSemver::Range.new(v).parse[0]
      end
    end

    def parse_hyphen(version)
      version.split('-').each_with_index.map do |v, i|
        v.strip!
        arr = v.split('.')
        if i.eql?(0)
          '>=' + fillup(v)
        elsif arr.size < 3
          arr[-1] = arr[-1].to_i + 1
          '<' + fillup(arr.join('.'))
        else
          '<=' + v
        end
      end
    end

    def parse_caret(version)
      arr = version.sub!('^', '').split('.')[0..2]
      if arr.size < 3
        index = (arr.size - 1).dup
        index -= 1 if arr[index] =~ /x|X/
        version.sub!(/x|X/, '0')
        low = '>=' + fillup(version)
        high = '<' + fillup(up(arr, index, true))
      else
        bit, index = non_zero_with_index(arr)
        index -= 1 if index == arr.size - 1 && bit =~ /x|X/
        version.sub!(/x|X/, '0')
        low = '>=' + version
        high = '<' + up(arr, index, true)
      end
      [low, high]
    end

    def non_zero_with_index(array)
      array.each_with_index do |v, i|
        return v, i unless v.eql?('0')
      end
    end

    def up(array, index, caret = false)
      array.each_with_index.map do |i, j|
        i = 0 if j > index
        i = 0 if caret && i =~ /x|X/
        i = i.to_i + 1 if j == index
        i
      end.join('.')
    end

    def parse_tilde(version)
      v = fillup(version.sub!('~', ''))
      arr = v.split('.')[0..2]
      high = if arr[1].eql?('0')
               up(arr, 0)
             else
               up(arr, 1)
             end
      ['>=' + v, '<' + high]
    end

    def parse_x(version)
      # '1.2.*'
      version = version.sub!(/X|\*/, 'x') || version
      arr = version.split('.')
      low = fillup(version.sub('x', '0'))
      index = if version =~ /x/
                arr.find_index('x') - 1
              else
                arr.size - 1
              end
      high = fillup(up(arr, index))
      ['>=' + low, '<' + high]
    end

    def fillup(version)
      # fillup 1.0 to 1.0.0
      size = version.split('.').size
      return version unless size < 3
      num = 3 - size
      num.times { version << '.0' } if num > 0
      version
    end
  end
end
