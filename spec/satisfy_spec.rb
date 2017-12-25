require 'spec_helper'

describe NodeSemver do
  it 'can satisfies' do
    expect(NodeSemver.satisfies('1.2.3', '>=1.0.0 <2.0.0')).to eq(true)
  end

  it 'can satisfies pipe' do
    expect(NodeSemver.satisfies('1.2.3', '0.0.9 || >=1.0.0 <2.0.0')).to eq(true)
  end

  it 'can maxsatisfying' do
    expect(NodeSemver.max_satisfying(['1.0.0', '1.0.1', '1.0.2'], '0.0.9 || >=1.0.0 <2.0.0')).to eq('1.0.2')
  end

  it 'can gtr a range' do
    expect(NodeSemver.gtr('1.2.3', '<1.0.0')).to eq(true)
  end

  it 'can gtr a pipe range' do
    expect(NodeSemver.gtr('1.2.3', '1.0.0 || <1.1.0')).to eq(true)
  end

  it 'can gtr a complicated range' do
    expect(NodeSemver.gtr('1.2.3', '>=1.0.0 <1.1.0 || 1.2.2')).to eq(true)
  end

  it 'can ltr a complicated range' do
    expect(NodeSemver.ltr('0.0.1', '>=0.0.5 <1.0.0 || 0.0.3')).to eq(true)
  end

  it 'can detect outside of range' do
    expect(NodeSemver.outside('1.2.3', '>=1.0.0 <1.1.0 || 1.2.2', '>')).to eq(true)
  end
end
