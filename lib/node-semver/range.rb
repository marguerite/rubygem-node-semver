module Semver
	class Range
		def initialize(version)
			@version = version
		end

		def parse
			if @version.index("||")
				parse_pipe(@version)
			elsif @version.index("\s-\s")
				parse_hyphen(@version)
			elsif @version.index("\s")
				parse_whitespace(@version)
			else
				if @version.start_with?("^")
					parse_caret(@version)
				elsif @version.start_with?("~")
					parse_tilde(@version)
				elsif @version == "*" || @version.empty?
					return [">=0.0.0"]
				elsif @version.index(/x|X|\*/)
					parse_x(@version)
				elsif />|<|=/.match(@version[0])
					version = fillup?(@version) ? fillup(@version) : @version
					return [version]
				elsif @version.split(".").size < 3
					version = fillup_x(@version)
					parse_x(version)
				else
					Semver.valid(@version).nil? ? nil : ["="+@version]
				end
			end
		end

		def validRange(raw=false)
			range = parse
			if range.instance_of?(Array)
				raw ? range : @version
			else
				nil
			end
		end

		private

		def parse_pipe(version)
			arr = version.split("||")
			arr.map! {|v| v.strip!}
			range = []
			arr.each do |item|
				item_range = Semver::Range.new(item).parse
				range << item_range
			end
			return range
		end

		def parse_hyphen(version)
			arr = version.split("-")
			arr.map! {|v| v.strip!}
			bottom_str = fillup?(arr[0]) ? fillup(arr[0]) : arr[0]
			bottom = ">=" + bottom_str

			up = ""
			if fillup?(arr[1])
				version = arr[1].dup
				version = fillup(version)
				regex = /(.)\.(.)\.(.)/.match(version)
				h = {:major=>regex[1],:minor=>regex[2],:patch=>regex[3]}
				index = arr[1].split(".").size - 1
				bit_to_up = h.keys[index]
				h[bit_to_up] = (h[bit_to_up].to_i + 1).to_s
				up = "<" + h.values[0] + "." + h.values[1] + "." + h.values[2]
			else
				up = "<=" + arr[1]
			end
			return [bottom,up]
		end

		def parse_whitespace(version)
			arr = version.split("\s")
			range = []
			arr.each do |item|
				item_range = Semver::Range.new(item).parse
				range = range + item_range
			end
			return range
		end

		def parse_caret(version)
			orig = version.dup
			version = fillup(version)
			regex = /(.)\.(.)\.(.).*/.match(version)
			h = {:major=>regex[1],:minor=>regex[2],:patch=>regex[3]}
			bit_to_up = ""

			if h.values.include?("x")
				if h.values[0] == "0"
					bit_to_up = h.keys[h.values.index("x") - 1]
				else
					bit_to_up = h.keys[0]
				end
			else
				nonzero = {}
				h.each {|k,v| nonzero[k] = v if v.to_i > 0}
				if nonzero.empty? # everything is 0, refers to "^0.0"
					bit_to_up = h.keys[3 - orig.split(".").size]
				else
					bit_to_up = nonzero.keys[0]
				end
			end
			h[bit_to_up] = (h[bit_to_up].to_i + 1).to_s
			up_index = h.keys.index(bit_to_up) + 1
			if 3 - up_index > 0
				for i in up_index..2 do
					h[h.keys[i]] = "0"
				end
			end

			up = h.values[0] + "." + h.values[1] + "." + h.values[2]
			if up == "0.0.0" && fillup?(version)
				up = "0.1.0"
			end
			bottom = version.sub("^","").sub("x","0")
			range = [">=" + bottom,"<" + up]
			return range
		end

		def parse_tilde(version)
			orig = version.dup
			version = fillup(version)
			regex = /(.)\.(.)\.(.).*/.match(version)
			h = {:major=>regex[1],:minor=>regex[2],:patch=>regex[3]}
			bottom = version.sub("~","")
			up_index = 0
			if orig.split(".").size < 2
				up_index = 1
				h[:major] = (h[:major].to_i + 1).to_s
			else
				up_index = 2
				h[:minor] = (h[:minor].to_i + 1).to_s
			end

			for i in up_index..2 do
				h[h.keys[i]] = "0"
			end

			up = h.values[0] + "." + h.values[1] + "." + h.values[2]
			range = [">=" + bottom, "<" + up]
			return range
		end

		def parse_x(version)
			version = fillup(version)
			regex = /(.)\.(.)\.(.)/.match(version)
			h = {:major=>regex[1],:minor=>regex[2],:patch=>regex[3]}
			bottom = version.gsub("x","0").gsub("*","0")

			up_index = h.values.index{|e| e =~ /x|\*/}
			bit_to_up = h.keys[up_index - 1]
			h[bit_to_up] = (h[bit_to_up].to_i + 1).to_s

			for i in up_index..2 do
				h[h.keys[i]] = "0"
			end
			up = h.values[0] + "." + h.values[1] + "." + h.values[2]
			range = [">=" + bottom, "<" + up]
			return range
		end

		def fillup(version)
			# fillup 1.0 to 1.0.0
			bits_to_fillup = 3 - version.split(".").size
			if bits_to_fillup > 0
				bits_to_fillup.times {version << ".0"}
			end
			return version
		end

		def fillup?(version)
			(3 - version.split(".").size) > 0 ? true : false
		end

		def fillup_x(version)
			bits_to_fillup = 3 - version.split(".").size
			if bits_to_fillup == 2
				return version + ".x.0"
			else
				return version + ".x"
			end
		end
	end
end
