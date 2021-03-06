
#
# Specifying rufus-tokyo
#
# Sun Feb  8 14:15:31 JST 2009
#

require File.dirname(__FILE__) + '/spec_base'

require 'rufus/tokyo/hmethods'


class MyHash
  include Rufus::Tokyo::HashMethods
  attr_accessor :default_proc
  def get (k)
    k.to_i % 2 == 0 ? k : nil
  end
end

describe 'an instance that include HashMethods' do

  before do
    @h = MyHash.new
  end

  it 'should be ready for testing' do # :(
    @h[1].should.be.nil
    @h[2].should.equal(2)
  end

  it 'should accept a default value' do
    @h.default = :default
    @h.default.should.equal(:default)
  end

  it 'should accept a default_proc' do
    @h.default_proc = lambda { |h, k| k * 2 }
    @h[1].should.equal(2)
    @h[2].should.equal(2)
    @h[3].should.equal(6)
  end
end

