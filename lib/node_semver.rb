require 'node_semver/range'
require 'node_semver/satisfy'
require 'node_semver/instance'
require 'node_semver/version'

module NodeSemver
  extend self

  h = { 'gt' => '>', 'gte' => '>=', 'lt' => '<',
        'lte' => '<=', 'eq' => '==', 'neq' => '!=' }
  h.each do |k, v|
    define_method k do |m, n|
      cmp(m, v, n)
    end
  end

  %w[major minor patch prerelease].each do |i|
    define_method i do |v|
      NodeSemver::Instance.new(v).send(i)
    end
  end

  class << self
    def valid(v)
      NodeSemver::Instance.new(v).valid
    end

    alias clean valid

    def inc(v, reltype, preid = 'prerelease')
      NodeSemver::Instance.new(v).inc(reltype, preid)
    end

    def cmp(v1, comparator, v2)
      v1 = NodeSemver::Instance.new(v1)
      v2 = NodeSemver::Instance.new(v2)
      return false if v1.send(:comparable?, v2)
      v1.send(comparator, v2)
    end

    def compare(v1, v2)
      v1 = NodeSemver::Instance.new(v1)
      v2 = NodeSemver::Instance.new(v2)
      return if v1.send(:comparable?, v2)
      v1 <=> v2
    end

    def rcompare(v1, v2)
      compare(v2, v1)
    end

    def sort(*args)
      args.map { |i| NodeSemver::Instance.new(i) }.sort.map(&:version)
    end

    def rsort(*args)
      sort(*args).reverse
    end

    def diff(v1, v2)
      NodeSemver::Instance.new(v1) - NodeSemver::Instance.new(v2)
    end
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
