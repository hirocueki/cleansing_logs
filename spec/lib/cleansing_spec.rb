require 'spec_helper'
require 'cleanser'

RSpec.describe Cleanser do
  context 'a' do
    it 'クラスのメソッドが動くこと' do
      kls = Cleanser.new('hoge.gz')
      expect(kls.gz_file).to eq 'hoge.gz'
    end

    it 'validates' do
      kls = Cleanser.new('hoge.gz')
      expect(kls).to be_validate(method: 'GET', file: '/mynews/hogehoge')
    end
  end
end
