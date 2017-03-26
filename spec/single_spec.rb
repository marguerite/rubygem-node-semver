require 'spec_helper'

describe NodeSemver do
  it 'can valid version' do
    str = ' =v1.2.65535-alpha.123+build.0  '
    expect(NodeSemver.valid(str)).to eq('1.2.65535-alpha.123')
  end

  it 'can clean version' do
    expect(NodeSemver.clean(' =v1.2.3')).to eq('1.2.3')
  end

  it 'can get major version' do
    expect(NodeSemver.major('1.2.3')).to eq(1)
  end

  it 'can get minor version' do
    expect(NodeSemver.minor('1.2.3')).to eq(2)
  end

  it 'can get patch version' do
    expect(NodeSemver.patch('1.2.3')).to eq(3)
  end

  it 'can get prerelease' do
    expect(NodeSemver.pre('1.2.3-alpha.0')).to eq('alpha.0')
  end

  it 'can get prerelease type' do
    expect(NodeSemver.pre_t('1.2.3-alpha.0')).to eq('alpha')
  end

  it 'can get prerelease number' do
    expect(NodeSemver.pre_n('1.2.3-alpha.0')).to eq(0)
  end

  it 'can increase major version' do
    expect(NodeSemver.inc('1.2.3-alpha.0', 'major')).to eq('2.2.3')
  end

  it 'can increase minor version' do
    expect(NodeSemver.inc('1.2.3-alpha.0', 'minor')).to eq('1.3.3')
  end

  it 'can increase patch version' do
    expect(NodeSemver.inc('1.2.3-alpha.0', 'patch')).to eq('1.2.4')
  end

  it 'can increase premajor version' do
    expect(NodeSemver.inc('1.2.3-alpha.1', 'premajor')).to eq('2.2.3-alpha.1')
  end

  it 'can increase preminor version' do
    expect(NodeSemver.inc('1.2.3-alpha.1', 'preminor')).to eq('1.3.3-alpha.1')
  end

  it 'can increase prepatch version' do
    expect(NodeSemver.inc('1.2.3-alpha.1', 'prepatch')).to eq('1.2.4-alpha.1')
  end

  it 'can increase prerelease version' do
    expect(NodeSemver.inc('1.2.3', 'prerelease')).to eq('1.2.4-alpha.1')
  end

  it 'can increase prerelease version' do
    expect(NodeSemver.inc('1.2.3-alpha.1', 'prerelease')).to eq('1.2.3-alpha.2')
  end
end
