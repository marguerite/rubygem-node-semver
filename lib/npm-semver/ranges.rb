module Semver
	class Ranges
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
				else @version.split(".").size < 3
					version = fillup_x(@version)
					parse_x(version)
				end
			end
		end

		private

		def parse_pipe(version)

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
				byte_to_up = h.keys[index]
				h[byte_to_up] = (h[byte_to_up].to_i + 1).to_s
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
				item_range = NPKG::Semver.new(item).parse
				range = range + item_range
			end
			return range
		end

		def parse_caret(version)
			version = fillup(version)
			regex = /(.)\.(.)\.(.).*/.match(version)
			h = {:major=>regex[1],:minor=>regex[2],:patch=>regex[3]}
			byte_to_up = ""

			if h.values.include?("x")
				if h.keys[0] == "0"
					byte_to_up = h.keys[h.values.index("x") - 1]
				else
					byte_to_up = h.keys[0]
				end
			else
				nonzero = {}
				h.each {|k,v| nonzero[k] = v if v.to_i > 0}
				byte_to_up = nonzero.keys[0]
			end

			h[byte_to_up] = (h[byte_to_up].to_i + 1).to_s
			up_index = h.keys.index(byte_to_up) + 1
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
			bottom = version.sub("x","0")
			up_index = h.values.index("x")
			byte_to_up = h.keys[h.values.index("x") - 1]
			h[byte_to_up] = (h[byte_to_up].to_i + 1).to_s

			for i in up_index..2 do
				h[h.keys[i]] = "0"
			end
			up = h.values[0] + "." + h.values[1] + "." + h.values[2]
			range = [">=" + bottom, "<" + up]
			return range
		end

		def fillup(version)
			# fillup 1.0 to 1.0.0
			bytes_to_fillup = 3 - version.split(".").size
			if bytes_to_fillup > 0
				bytes_to_fillup.times {version << ".0"}
			end
			return version
		end

		def fillup?(version)
			3 - version.split(".").size ? true : false
		end

		def fillup_x(version)
			bytes_to_fillup = 3 - version.split(".").size
			if bytes_to_fillup == 2
				return version + ".x.0"
			else
				return version + ".x"
			end
		end
	end
end
