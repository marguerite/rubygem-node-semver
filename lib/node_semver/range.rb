module NodeSemver
  class Range
    def initialize(version)
      @version = version
    end

    def parse
      if @version.index('||')
        parse_pipe(@version)
      elsif @version.index("\s-\s")
        parse_hyphen(@version)
      elsif @version.index("\s")
        parse_whitespace(@version)
      elsif @version.start_with?('^')
        parse_caret(@version)
      elsif @version.start_with?('~')
        parse_tilde(@version)
      elsif @version == '*' || @version.empty?
        ['>=0.0.0']
      elsif @version.index(/x|X|\*/)
        parse_x(@version)
      elsif @version[0] =~ />|<|=/
        version = fillup?(@version) ? fillup(@version) : @version
        [version]
      elsif @version.split('.').size < 3
        version = fillup_x(@version)
        parse_x(version)
      else
        NodeSemver::Instance.new(@version).valid.nil? ? nil : ['=' + @version]
      end
    end

    def valid_range
      range = parse
      raise 'Not a range' unless range.instance_of?(Array)
      range
    end

    private

    def parse_pipe(version)
      arr = version.split('||')
      arr.map!(&:strip!)
      range = []
      arr.each do |item|
        item_range = NodeSemver::Range.new(item).parse
        range << item_range
      end
      range
    end

    def parse_hyphen(version)
      arr = version.split('-')
      arr.map!(&:strip!)
      bottom_str = fillup?(arr[0]) ? fillup(arr[0]) : arr[0]
      bottom = '>=' + bottom_str

      up = ''
      if fillup?(arr[1])
        version = arr[1].dup
        version = fillup(version)
        regex = /(.)\.(.)\.(.)/.match(version)
        h = { major: regex[1], minor: regex[2], patch: regex[3] }
        index = arr[1].split('.').size - 1
        bit_to_up = h.keys[index]
        h[bit_to_up] = (h[bit_to_up].to_i + 1).to_s
        up = '<' + h.values[0] + '.' + h.values[1] + '.' + h.values[2]
      else
        up = '<=' + arr[1]
      end
      [bottom, up]
    end

    def parse_whitespace(version)
      # Make sure number are like >=1.0.0 not like >= 1.0.0
      version.gsub!("> ", ">")
      version.gsub!(">= ", ">=")
      version.gsub!("< ", "<")

      arr = version.split("\s")
      # normally this is to parse ">=1.0.0 <2.0.0", but sometimes
      # ">= 1.0.0" goes here too
      if arr.size == 2 && !arr.reject {|i| i =~ /\d+/}.empty?
        return NodeSemver::Range.new(arr[0] + arr[1]).parse
      end
      range = []
      arr.each do |item|
        item_range = NodeSemver::Range.new(item).parse
        range += item_range
      end
      range
    end

    def parse_caret(version)
      orig = version.dup
      version = fillup(version).sub('^', '')
      regex = /(\d+)\.(\d+|x|X|\*)\.(\d+|x|X|\*).*/.match(version)
      h = { major: regex[1], minor: regex[2], patch: regex[3] }
      bit_to_up = ''

      if h.values.include?('x')
        bit_to_up = if h.values[0] == '0'
                      h.keys[h.values.index('x') - 1]
                    else
                      h.keys[0]
                    end
      else
        nonzero = {}
        h.each { |k, v| nonzero[k] = v if v.to_i > 0 }
        bit_to_up = if nonzero.empty? # everything is 0, refers to "^0.0"
                      h.keys[3 - orig.split('.').size]
                    else
                      nonzero.keys[0]
                    end
      end
      h[bit_to_up] = (h[bit_to_up].to_i + 1).to_s
      up_index = h.keys.index(bit_to_up) + 1
      if 3 - up_index > 0
        (up_index..2).each do |i|
          h[h.keys[i]] = '0'
        end
      end

      up = h.values[0] + '.' + h.values[1] + '.' + h.values[2]
      up = '0.1.0' if up == '0.0.0' && fillup?(version)
      bottom = version.sub('x', '0')
      range = ['>=' + bottom, '<' + up]
      range
    end

    def parse_tilde(version)
      orig = version.dup
      version = fillup(version).sub('~', '').sub('x', '0')
      # 1.2.3-beta.2
      regex = /(\d+)\.(\d+|x|X|\*)\.(\d+|x|X|\*).*/.match(version)
      h = { major: regex[1], minor: regex[2], patch: regex[3] }
      bottom = version

      up_index = 0
      if orig.split('.').size < 2
        up_index = 1
        h[:major] = (h[:major].to_i + 1).to_s
      else
        up_index = 2
        h[:minor] = (h[:minor].to_i + 1).to_s
      end

      (up_index..2).each do |i|
        h[h.keys[i]] = '0'
      end

      up = h.values[0] + '.' + h.values[1] + '.' + h.values[2]
      range = ['>=' + bottom, '<' + up]
      range
    end

    def parse_x(version)
      version = fillup(version)
      regex = /(\d+)\.(\d+|x|X|\*)\.(\d+|x|X|\*)/.match(version)
      h = { major: regex[1], minor: regex[2], patch: regex[3] }
      bottom = version.gsub(/x|X|\*/, '0')

      up_index = h.values.index { |e| e =~ /x|X|\*/ }
      bit_to_up = h.keys[up_index - 1]
      h[bit_to_up] = (h[bit_to_up].to_i + 1).to_s

      (up_index..2).each do |i|
        h[h.keys[i]] = '0'
      end
      up = h.values[0] + '.' + h.values[1] + '.' + h.values[2]
      range = ['>=' + bottom, '<' + up]
      range
    end

    def fillup(version)
      # fillup 1.0 to 1.0.0
      bits_to_fillup = 3 - version.split('.').size
      bits_to_fillup.times { version << '.0' } if bits_to_fillup > 0
      version
    end

    def fillup?(version)
      3 - version.split('.').size > 0 ? true : false
    end

    def fillup_x(version)
      3 - version.split('.').size == 2 ? version + '.x.0' : version + '.x'
    end
  end
end
