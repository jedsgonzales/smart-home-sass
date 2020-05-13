require 'rails_helper'
require 'automation/api/smart_g4/message'

RSpec.describe Automation::Api::SmartG4 do
  before(:all) do
    @lead_ip = [192, 168, 1, 1]
    @head_code = [0x53, 0x4D, 0x41, 0x52, 0x54, 0x43, 0x4C, 0x4F, 0x55, 0x44]
    @correct = [0xAA, 0xAA, 0x0F, 0x01, 0xFA, 0xFF, 0xFE, 0x00, 0x31, 0x01, 0x44, 0x01, 0x46, 0x00, 0x00, 0x1D, 0xA3]
    @wrong = [0xAA, 0xAA, 0x0F, 0x01, 0xFA, 0xFF, 0xFE, 0x00, 0x31, 0x01, 0x44, 0x01, 0x46, 0x00, 0x00, 0x2E, 0xA3]
    @broken = [ 0xAA, 0xAA, 0x0F, 0x01, 0xFA, 0xFF, 0xFE, 0x00, 0x31, 0x01, 0x44 ]
    @excess = @broken

    @sample1 = Automation::Api::SmartG4::Message.consume(@correct)

    @sample2 = Automation::Api::SmartG4::Message.consume(@wrong + @excess)

    @sample3 = Automation::Api::SmartG4::Message.consume(@broken)

    @sample4 = Automation::Api::SmartG4::Message.consume(@broken + @correct)

    @sample5 = Automation::Api::SmartG4::Message.consume(@lead_ip + @head_code + @correct)
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
      expect(@sample2[:excess].size).to eql(@excess.size)
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

    it 'will yield buffer on incomplete set and return excess of complete set' do
      expect(@sample4[:is_broken]).to be true
      expect(@sample4[:buffer]).to eql(@broken)
      expect(@sample4[:excess]).to eql(@correct)
    end

    it 'can detect origin ip address if present' do
      expect(@sample5[:message]).not_to be_nil
      expect(@sample5[:message].origin_ip).to eql(@lead_ip.join('.'))
    end
  end
end
