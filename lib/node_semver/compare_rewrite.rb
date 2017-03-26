module Semver
  class Compare
    include Comparable

    def initialize(v1, v2)
      @v1 = Semver.valid(v1)
      @v2 = Semver.valid(v2)
    end

    def <=>

    end

    private

    def compare_main
      r = [Semver.major(@v1) <=> Semver.major(@v2), 
           Semver.minor(@v1) <=> Semver.minor(@v2),
           Semver.patch(@v1) <=> Semver.patch(@v2)].reject!(&:zero?)
      r.empty? ? 0 : r[0]
    end

    def compare_pretype
      p1 = Semver.pre_t(@v1)
      p2 = Semver.pre_t(@v2)

      if p1.nil? && p2.nil?
        0
      elsif p1.nil? && !p2.nil?
        1
      elsif !p1.nil? && p2.nil?
        -1
      else
        p1 <=> p2
      end
    end

    def compare_pre
      return compare_pretype unless compare_pretype.zero?
      n1 = Semver.pre_n(@v1)
      n2 = Semver.pre_n(@v2)
      n1 <=> n2
    end

    def compare_ver
      compare_main.zero? ? compare_pre : compare_main
    end
  end
end

require '../node-semver.rb'
require './single.rb'

p Semver::Compare.new('1.0.0-alpha.0', '1.0.0-alpha.1').compare_pre
