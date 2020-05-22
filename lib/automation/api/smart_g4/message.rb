require 'resolv'
require 'automation/api/smart_g4'

module Automation
  module Api
    module SmartG4
      class Message
        PACKET = Automation::Api::SmartG4::PACKET

        # class methods

        # creates Message object from given contents
        # contents must be array of message bytes
        # returns a hash containing the message absorbed
        # and the packets that came after that treated as
        # excess from processing
        def self.consume(contents = [])
          message = nil
          clean_packet = []
          excess_packet = []

          excess_from = -1
          lead_code_index = -1
          msg_length = 0

          retrieve = false

          contents.each_with_index do |content, index|
            if retrieve && contents[index, PACKET[:lead_code].size ] == PACKET[:lead_code]
              # if already in retrieve mode then we encountered the headers lead code again
              # cut off extracting and treat suceeding contents as excess
              excess_from = index
              break
            end

            # not yet retrieving, detect [ ... 0xAA, 0xAA, ... ] presence inside the contents
            if !retrieve &&
                contents[index, PACKET[:lead_code].size ] == PACKET[:lead_code] &&
                contents[index + PACKET[:lead_code].size] != nil # can retrieve length

              lead_code_index = index
              msg_length = contents[index + PACKET[:lead_code].size]

              # check if given length less than retrievable from contents
              if contents.size < (index + (PACKET[:lead_code].size - 1) + msg_length)
                clean_packet = contents.dup
                break # incomplete packet, msg_length exceeds actual contents size
              end

              retrieve = true # signal retrieving from current position if all is well
            end

            if retrieve
               # watch out for size of data we are trying to retrieve, rest will be excess=
              if clean_packet.size < (msg_length + PACKET[:lead_code].size)
                # puts "cleanpacket push #{content.to_s(16)}"
                clean_packet.push(content)
              else
                excess_from = index
                break # stop loop
              end
            end
          end #contents.each_with_index

          unless excess_from < 0
            while excess_from < contents.size
              excess_packet.push( contents[excess_from] )
              excess_from += 1
            end
          end

          # compose message object from cleaned packet
          # at this points it should contain the proper
          # base structure, if not empty
          unless clean_packet.empty?
            #puts "clean packet #{clean_packet.collect{|d| d.to_s(16) }}"
            # are we able to obtain the whole size starting from lead code headers
            if clean_packet.size == (msg_length + PACKET[:lead_code].size)
              # set start index for retrieval
              fld_idx = PACKET[:lead_code].size

              # obtain origin ip
              origin_ip = ''
              possible_position = lead_code_index - PACKET[:head_code].size - 4 # 4 is IPV4 length
              if possible_position >= 0
                ip = contents[possible_position, 4].join('.')
                origin_ip = ip if (ip =~ Resolv::IPv4::Regex)
              end

              #puts "consume content #{clean_packet[(fld_idx + 9)..(clean_packet.size - 3)]}"
              #puts "consume crc #{clean_packet[(clean_packet.size - 2), 2]}"

              message = Message.new(
                origin_subnet: clean_packet[fld_idx + 1],
                origin_device_id: clean_packet[fld_idx + 2],
                origin_device_type:  clean_packet[fld_idx + 3, 2],
                op_code: clean_packet[fld_idx + 5, 2],
                target_subnet:  clean_packet[fld_idx + 7],
                target_device_id:  clean_packet[fld_idx + 8],
                content:  clean_packet[(fld_idx + 9)..(clean_packet.size - 3)],
                crc: clean_packet[(clean_packet.size - 2), 2],
                origin_ip: origin_ip
              )
            end
          end

          # return
          { message: message, excess: excess_packet, is_broken: message.nil? && clean_packet.any?, buffer: clean_packet, index: lead_code_index }
        end

        # utility for calculating CRCs
        def self.calculate_crc(packets:)
          crc = 0 # word
          dat = 0 # byte

          packets.each do |data|
            dat = (crc >> 8) & 0xFF
            crc = (crc << 8) & 0xFFFF

            crc = (crc ^ CRC_TAB[dat ^ data]) & 0xFFFF
          end

          crc.digits(256).reverse
        end

        # utility for verifying CRCs
        def self.verify_crc(packets:, crc_bytes:)
          result_crc = self.calculate_crc(packets: packets)
          crc_bytes.first == result_crc.first && crc_bytes.last == result_crc.last
        end

        # instance attr readers
        attr_accessor :origin_ip

        attr_reader :length
        attr_reader :origin_subnet
        attr_reader :origin_device_type
        attr_reader :origin_device_id
        attr_reader :op_code
        attr_reader :target_subnet
        attr_reader :target_device_id
        attr_reader :content
        attr_reader :crc

        def initialize(
          origin_subnet:,
          origin_device_id:,
          origin_device_type:,
          op_code:,
          target_subnet:,
          target_device_id:,
          content:,
          crc: nil,
          origin_ip: '')

          @origin_ip = origin_ip

          @origin_subnet = origin_subnet
          @origin_device_type = origin_device_type.kind_of?(Numeric) ? origin_device_type.digits(256).reverse : origin_device_type
          @origin_device_id = origin_device_id
          @op_code = op_code.kind_of?(Numeric) ? op_code.digits(256).reverse : op_code
          @target_subnet = target_subnet
          @target_device_id = target_device_id
          @content = content

          @origin_device_type.unshift(0) if @origin_device_type.size == 1
          @op_code.unshift(0) if @op_code.size == 1

          # 1 from length byte
          # 2 from crc bytes
          @length = pure.size + 3

          # calculate crc's
          if crc.nil?
            @crc = Message.calculate_crc(packets: self.raw)
            @is_valid = true
          else
            @crc = crc.kind_of?(Array) ? crc : [0, 0]
            @is_valid = Message.verify_crc(packets: self.raw, crc_bytes: @crc)
          end

        end

        def is_valid?
          !!@is_valid
        end

        def op_code_val
          @op_code.collect{ |d| d.to_s(16) }.join('').to_i(16)
        end

        def origin_device_type_val
          @origin_device_type.collect{ |d| d.to_s(16) }.join('').to_i(16)
        end

        # returns array of int values representing the bytes of packet
        def complete
          PACKET[:lead_code] +
            self.raw +
            self.crc
        end

        def raw
            self.length.digits(256).reverse +
            self.pure
        end

        def pure
            self.origin_subnet.digits(256).reverse +
            self.origin_device_id.digits(256).reverse +
            self.origin_device_type +
            self.op_code +
            self.target_subnet.digits(256).reverse +
            self.target_device_id.digits(256).reverse +
            self.content # this should already be the ordered bytes
        end

        def to_str
          self.complete.collect{ |b| b.to_s(16) }
        end

      end
    end
  end
end
