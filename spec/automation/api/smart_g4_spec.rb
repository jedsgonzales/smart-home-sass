require 'rails_helper'
require 'automation/api/smart_g4'

RSpec.describe Automation::Api::SmartG4 do
  before(:all) do
    @correct = [0xAA, 0xAA, 0x0F, 0x01, 0xFA, 0xFF, 0xFE, 0x00, 0x31, 0x01, 0x44, 0x01, 0x46, 0x00, 0x00, 0x1D, 0xA3]
    @sample1 = Automation::Api::SmartG4::Message.consume(@correct)

    @wrong = [0xAA, 0xAA, 0x0F, 0x01, 0xFA, 0xFF, 0xFE, 0x00, 0x31, 0x01, 0x44, 0x01, 0x46, 0x00, 0x00, 0x2E, 0xA3]
    @excess = [0x00, 0x01]
    @sample2 = Automation::Api::SmartG4::Message.consume(@wrong + @excess)

    @broken = [ 0xAA, 0xAA, 0x0F, 0x01, 0xFA, 0xFF, 0xFE, 0x00, 0x31, 0x01, 0x44 ]
    @sample3 = Automation::Api::SmartG4::Message.consume(@broken)
    
  end

  context 'calculate_crc' do
    it 'can calculate correct crc' do
      result = Automation::Api::SmartG4::Message.calculate_crc(packets: [
          0x0F, 0x01, 0xFA, 0xFF, 0xFE, 0x00, 0x31, 0x01, 0x44, 0x01, 0x46, 0x00, 0x00
      ])

      expect(result).to eql([0x1D, 0xA3])
    end
  end

  context 'consume' do
    it 'will create a Message object from a valid packet' do
      expect(@sample1[:message]).not_to be_nil
    end

    it 'can detect if message crc is valid' do
      expect(@sample1[:message].is_valid?).to be true
    end

    it 'can detect if message crc is invalid' do
      expect(@sample2[:message].is_valid?).to be false
    end

    it 'will yield no excess contents at exact set' do
      expect(@sample1[:excess].size).to eql(0)
    end

    it 'will yield no excess contents on overflow' do
      expect(@sample2[:excess].size).to eql(2)
    end

    it 'will yield exact excess contents on overflow' do
      expect(@sample2[:excess]).to eql(@excess)
    end

    it 'will not yield message on incomplete set' do
      expect(@sample3[:message]).to be_nil
    end

    it 'will yield is_broken on incomplete set' do
      expect(@sample3[:is_broken]).to be true
    end

    it 'will yield buffer on incomplete set' do
      expect(@sample3[:buffer]).to eql(@broken)
    end
  end
end
