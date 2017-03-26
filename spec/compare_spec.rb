require 'spec_helper'

describe NodeSemver do
  it 'can compare greater' do
    expect(NodeSemver.gt('1.2.3', '1.2.2')).to eq(true)
  end

  it 'can compare lower' do
    expect(NodeSemver.lt('1.2.3', '1.2.4')).to eq(true)
  end

  it 'can compare greater and equal' do
    expect(NodeSemver.gte('1.2.3', '1.2.4')).to eq(false)
  end

  it 'can compare lower and equal' do
    expect(NodeSemver.lte('1.2.3', '1.2.0')).to eq(false)
  end

  it 'can compare equal' do
    expect(NodeSemver.eq('1.2.3', '1.2.3')).to eq(true)
  end

  it 'can compare neq' do
    expect(NodeSemver.neq('1.2.3', '1.2.3')).to eq(false)
  end

  it 'can cmp' do
    expect(NodeSemver.cmp('1.2.3', '>', '1.2.0')).to eq(true)
  end

  it 'can compare' do
    expect(NodeSemver.compare('1.2.3', '1.2.3')).to eq(0)
  end

  it 'can rcompare' do
    expect(NodeSemver.rcompare('1.2.3', '1.2.4')).to eq(1)
  end

  it 'can diff major' do
    expect(NodeSemver.diff('1.2.3', '2.2.3')).to eq('major')
  end

  it 'can diff minor' do
    expect(NodeSemver.diff('1.2.3', '1.3.3')).to eq('minor')
  end

  it 'can diff patch' do
    expect(NodeSemver.diff('1.2.3', '1.2.4')).to eq('patch')
  end

  it 'can sort versions' do
    arr = ['0.0.3', '0.0.6', '0.0.4', '0.0.1']
    expect(NodeSemver.sort(arr)).to eq(['0.0.1', '0.0.3', '0.0.4', '0.0.6'])
  end

  it 'can reverse sort versions' do
    arr = ['0.0.3', '0.0.6', '0.0.4', '0.0.1']
    expect(NodeSemver.rsort(arr)).to eq(['0.0.6', '0.0.4', '0.0.3', '0.0.1'])
  end
end
