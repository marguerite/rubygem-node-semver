require 'node_semver/compare.rb'
require 'node_semver/exception.rb'
require 'node_semver/range.rb'
require 'node_semver/satisfy.rb'
require 'node_semver/instance.rb'
require 'node_semver/version.rb'

module NodeSemver
  extend self
  def method_missing(reltype, v)
    super unless RELTYPES.include?(reltype.to_s)
    NodeSemver::Instance.new(v).send(reltype)
  end

  def respond_to_missing(reltype)
    RELTYPES.include?(reltype.to_s) || super
  end
end

module NodeSemver
  class << self
    def valid(v)
      NodeSemver::Instance.new(v).valid
    end

    alias_method :clean, :valid

    def self.inc(v, reltype)
      NodeSemver::Instance.new(v).inc(reltype)
    end
  end

  def self.gt(v1, v2)
    NodeSemver::Comparison.new(v1, v2).gt
  end

  def self.gte(v1, v2)
    NodeSemver::Comparison.new(v1, v2).gte
  end

  def self.lt(v1, v2)
    NodeSemver::Comparison.new(v1, v2).lt
  end

  def self.lte(v1, v2)
    NodeSemver::Comparison.new(v1, v2).lte
  end

  def self.eq(v1, v2)
    NodeSemver::Comparison.new(v1, v2).eq
  end

  def self.neq(v1, v2)
    NodeSemver::Comparison.new(v1, v2).neq
  end

  def self.cmp(v1, comparator, v2)
    NodeSemver::Comparison.new(v1, v2).cmp(comparator)
  end

  def self.compare(v1, v2)
    NodeSemver::Comparison.new(v1, v2).compare
  end

  def self.rcompare(v1, v2)
    NodeSemver::Comparison.new(v2, v1).compare
  end

  def self.diff(v1, v2)
    NodeSemver::Comparison.new(v1, v2).diff
  end

  def self.sort(list)
    loop do
      flag = false
      (1..list.size - 1).each do |i|
        next unless NodeSemver::Comparison.new(list[i - 1], list[i]).gt
        tmp = list[i].dup
        list[i] = list[i - 1].dup
        list[i - 1] = tmp
        flag = true
      end
      break if flag == false
    end

    list
  end

  def self.rsort(list)
    loop do
      flag = false
      (1..list.size - 1).each do |i|
        next unless NodeSemver::Comparison.new(list[i - 1], list[i]).lt
        tmp = list[i]
        list[i] = list[i - 1]
        list[i - 1] = tmp
        flag = true
      end
      break if flag == false
    end

    list
  end

  def self.valid_range(range)
    NodeSemver::Range.new(range).valid_range
  end

  def self.satisfies(version, range)
    NodeSemver::Satisfaction.new(version, range).satisfy
  end

  def self.max_satisfying(versions, range)
    satisfied_versions = []
    versions.each do |v|
      satisfied_versions << v if NodeSemver.satisfies(v, range)
    end
    satisfied_versions.empty? ? nil : satisfied_versions.sort[-1]
  end

  def self.gtr(version, range)
    NodeSemver::Satisfaction.new(version, range).gtr
  end

  def self.ltr(version, range)
    NodeSemver::Satisfaction.new(version, range).ltr
  end

  def self.outside(version, range, hilo = nil)
    NodeSemver::Satisfaction.new(version, range).outside(hilo)
  end
end
