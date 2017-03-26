require 'node_semver/compare.rb'
require 'node_semver/exception.rb'
require 'node_semver/range.rb'
require 'node_semver/satisfy.rb'
require 'node_semver/single.rb'
require 'node_semver/version.rb'

module NodeSemver
  def self.valid(v)
    NodeSemver::Single.new(v).valid
  end

  def self.clean(v)
    raise "You can't clean an invalid version" if valid(v).nil?
    NodeSemver::Single.new(v).clean
  end

  def self.major(v)
    raise "You can't get major number for invalid version!" if valid(v).nil?
    NodeSemver::Single.new(v).major
  end

  def self.minor(v)
    raise "You can't get minor number for invalid version!" if valid(v).nil?
    NodeSemver::Single.new(v).minor
  end

  def self.patch(v)
    raise "You can't get patch number for invalid version!" if valid(v).nil?
    NodeSemver::Single.new(v).patch
  end

  def self.pre(v)
    raise "You can't get prerelease string for invalid version!" if valid(v).nil?
    NodeSemver::Single.new(v).pre
  end

  def self.pre_t(v)
    raise "You can't get prerelease type for invalid version!" if valid(v).nil?
    NodeSemver::Single.new(v).pre_t
  end

  def self.pre_n(v)
    raise "You can't get prerelease number for invalid version!" if valid(v).nil?
    NodeSemver::Single.new(v).pre_n
  end

  def self.inc(v, releasetype)
    raise "You can't increase version for invalid version!" if valid(v).nil?
    NodeSemver::Single.new(v).inc(releasetype)
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
