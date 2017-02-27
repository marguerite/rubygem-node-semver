module Semver
  class Comparison
    def initialize(v1, v2)
      @v1 = Semver.valid(v1)
      @v2 = Semver.valid(v2)
    end

    def gt
      compare_ver > 0 ? true : false
    end

    def gte
      compare_ver >= 0 ? true : false
    end

    def lt
      compare_ver < 0 ? true : false
    end

    def lte
      compare_ver <= 0 ? true : false
    end

    def eq
      compare_ver.zero? ? true : false
    end

    def neq
      compare_ver != 0 ? true : false
    end

    def cmp(comparator)
      case comparator
      when '>'
        gt
      when '>='
        gte
      when '<'
        lt
      when '<='
        lte
      when '=', '=='
        eq
      when '!='
        neq
      else
        raise InvalidComparator, "Invalid Comparator: " + comparator
      end
    end

    def compare
      if gt
        1
      elsif lt
        -1
      else
        0
      end
    end

    def diff
      if eq
        nil
      elsif Semver.pre_t(@v1).nil? && Semver.pre_t(@v2).nil?
        if Semver.major(@v1) != Semver.major(@v2)
          'major'
        elsif Semver.minor(@v1) != Semver.minor(@v2)
          'minor'
        else
          Semver.patch(@v1) != Semver.patch(@v2) ? 'patch' : nil
        end
      elsif Semver.major(@v1) != Semver.major(@v2)
        'premajor'
      elsif Semver.minor(@v1) != Semver.minor(@v2)
        'preminor'
      elsif Semver.patch(@v1) != Semver.patch(@v2)
        'prepatch'
      elsif compare_pre.zero?
        nil
      else
        'prerelease'
      end
    end

    private

    def compare_ver
      compare_main.zero? ? compare_pre : compare_main
    end

    def compare_num(n1, n2)
      if n1 > n2
        1
      elsif n1 < n2
        -1
      end
    end

    def compare_main
      r = compare_num(Semver.major(@v1), Semver.major(@v2)) || compare_num(Semver.minor(@v1), Semver.minor(@v2)) || compare_num(Semver.patch(@v1), Semver.patch(@v2))
      r.nil? ? 0 : r
    end

    def compare_pre
      if compare_pretype > 0
        1
      elsif compare_pretype < 0
        -1
      elsif Semver.pre_n(@v1).nil? && Semver.pre_n(@v2).nil?
        0
      else
        r = compare_num(Semver.pre_n(@v1), Semver.pre_n(@v2))
        r.nil? ? 0 : r
      end
    end

    def compare_pretype
      prev1 = Semver.pre_t(@v1)
      prev2 = Semver.pre_t(@v2)
      if prev1.nil? && prev2.nil?
        # both have no Pretype, equal
        0
      elsif prev1.nil? && !prev2.nil?
        # prev1 doesn't have prerelease while prev2 has
        # we only compare prerelease when main are the same
        # released version is greater than prerelease one
        1
      elsif prev2.nil? && !prev1.nil?
        -1
      elsif prev1[0] > prev2[0]
        # Alphabetically, a < b < r
        1
      elsif prev1[0] < prev2[0]
        -1
      else
        0
      end
    end
  end
end
