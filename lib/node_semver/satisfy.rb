module NodeSemver
  class Satisfaction
    def initialize(version, range)
      @version = NodeSemver.valid(version)
      @range = NodeSemver::Range.new(range).valid_range
    end

    def satisfy
      if @range[0].instance_of?(Array)
        result = false
        @range.each do |r|
          if fit?(@version, r)
            return true
          end
        end
	result
      else
        fit?(@version, @range)
      end
    end

    def gtr
      if @range[0].instance_of?(Array)
        arr = []
        @range.each { |r| arr << single_gtr(@version, r) }
        arr.include?(false) ? false : true
      else
        single_gtr(@version, @range)
      end
    end

    def ltr
      if @range[0].instance_of?(Array)
        arr = []
        @range.each { |r| arr << single_ltr(@version, r) }
        arr.include?(false) ? false : true
      else
        single_ltr(@version, @range)
      end
    end

    def outside(hilo = nil)
      case hilo
      when '>'
        gtr
      when '<'
        ltr
      else # nil
        if gtr == false && ltr == false
          false
        else
          true
        end
      end
    end

    private

    def unify(range)
      unified_arr = []
      # category first
      gt_arr = []
      gte_arr = []
      eq_arr = []
      lt_arr = []
      lte_arr = []

      range.each do |item|
        regex = /(>|>=|<|<=|=)?(\d+.*)/
        comparator = regex.match(item)[1]
        version = regex.match(item)[2]
        case comparator
        when '>='
          gte_arr << version
        when '>'
          gt_arr << version
        when '='
          eq_arr << version
        when '<='
          lte_arr << version
        when '<'
          lt_arr << version
        end
      end

      # combine gt_arr and gte_arr
      # [>1.1.0] [>=1.0.0]
      # need the smaller one
      if gt_arr.empty? || gte_arr.empty?
        # fill with the non-empty one
        unified_arr << '>' + max(gt_arr) unless gt_arr.empty?
        unified_arr << '>=' + max(gte_arr) unless gte_arr.empty?
      else
        max_gt = max(gt_arr)
        max_gte = max(gte_arr)
        unified_arr << if NodeSemver.gte(max_gt, max_gte)
                         '>=' + max_gte
                       else
                         '>' + max_gt
                       end
      end

      # combine lt_arr and lte_arr
      # [<=1.0.0] [<2.0.0]
      # need the bigger one
      if lt_arr.empty? || lte_arr.empty?
        # fill with the non-empty one
        unified_arr << '<' + max(lt_arr) unless lt_arr.empty?
        unified_arr << '<=' + max(lte_arr) unless lte_arr.empty?
      else
        max_lt = max(lt_arr)
        max_lte = max(lte_arr)
        unified_arr << if NodeSemver.gte(max_lte, max_lt)
                         '<=' + max_lte
                       else
                         '<' + max_lt
                       end
      end

      # judge eq in this range
      # [>=1.0.0,<2.0.0]
      unless eq_arr.empty?
        unless unified_arr.empty?
          # delete if item has already fit in unified_arr
          eq_arr.delete_if do |item|
            fit?(item, unified_arr)
          end
        end

        eq_arr.each { |i| unified_arr << '=' + i } unless eq_arr.empty?
      end

      unified_arr
    end

    def max(arr)
      max = ''
      arr.uniq.each do |item|
        prev = (arr.index(item) - 1 < 0 ? 0 : arr.index(item) - 1)
        max = item if NodeSemver.gte(item, arr[prev])
      end

      max
    end

    def fit(v, r)
      regex = /(>=|>|<=|<|=)(\d+.*)/
      comparator = regex.match(r)[1]
      comparator = '==' if comparator == '='
      version = regex.match(r)[2]
      NodeSemver.cmp(v, comparator, version)
    end

    def fit?(v, r)
      range = unify(r)
      result = []
      range.each do |item|
        result << fit(v, item)
      end
      !result.include?(false)
    end

    def single_gtr(v, r)
      unified_range = unify(r)
      result = []

      eq_range = unified_range.dup.keep_if { |k| k.start_with?('=') }
      lt_range = unified_range.dup.keep_if { |k| k.start_with?('<', '<=') }
      gt_range = unified_range.dup.keep_if { |k| k.start_with?('>', '>=') }

      unless eq_range.empty?
        eq_range.each do |i|
          # if it's in/lower than the range, then it can't be greater than the range.
          result << NodeSemver.gt(v, i.delete('='))
        end
      end

      unless lt_range.empty?
        result << (fit?(v, lt_range) ? false : true)
      end

      unless gt_range.empty?
        if lt_range.empty?
          result << false
        elsif eq_range.empty?
          result << (fit?(v, lt_range) ? false : true)
        elsif fit?(v, lt_range)
          result << false
        else
          eq_range.each do |i|
            result << NodeSemver.gt(v, i.delete('='))
          end
        end
      end
      result.include?(false) ? false : true
    end

    def single_ltr(v, r)
      unified_range = unify(r)
      result = []

      eq_range = unified_range.dup.keep_if { |k| k.start_with?('=') }
      lt_range = unified_range.dup.keep_if { |k| k.start_with?('<', '<=') }
      gt_range = unified_range.dup.keep_if { |k| k.start_with?('>', '>=') }

      unless eq_range.empty?
        eq_range.each do |i|
          # if it's in/greater than the range, then it can't be lower than the range.
          result << NodeSemver.lt(v, i.delete('='))
        end
      end

      unless gt_range.empty?
        result << (fit?(v, gt_range) ? false : true)
      end

      unless lt_range.empty?
        if gt_range.empty?
          result << false
        elsif eq_range.empty?
          result << (fit?(v, gt_range) ? false : true)
        elsif fit?(v, gt_range)
          result << false
        else
          eq_range.each do |i|
            result << NodeSemver.gt(v, i.delete('='))
          end
        end
      end

      result.include?(false) ? false : true
    end
  end
end
