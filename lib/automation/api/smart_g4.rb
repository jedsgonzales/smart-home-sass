module Automation
  module Api
    module SmartG4
      VERSION = 1.4.freeze

      CRC_TAB = [ # CRC Table
        0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
        0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef,
        0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6,
        0x9339, 0x8318, 0xb37b, 0xa35a, 0xd3bd, 0xc39c, 0xf3ff, 0xe3de,
        0x2462, 0x3443, 0x0420, 0x1401, 0x64e6, 0x74c7, 0x44a4, 0x5485,
        0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d,
        0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6, 0x5695, 0x46b4,
        0xb75b, 0xa77a, 0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d, 0xc7bc,
        0x48c4, 0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823,
        0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969, 0xa90a, 0xb92b,
        0x5af5, 0x4ad4, 0x7ab7, 0x6a96, 0x1a71, 0x0a50, 0x3a33, 0x2a12,
        0xdbfd, 0xcbdc, 0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a,
        0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41,
        0xedae, 0xfd8f, 0xcdec, 0xddcd, 0xad2a, 0xbd0b, 0x8d68, 0x9d49,
        0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70,
        0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 0x9f59, 0x8f78,
        0x9188, 0x81a9, 0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e, 0xe16f,
        0x1080, 0x00a1, 0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046, 0x6067,
        0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e,
        0x02b1, 0x1290, 0x22f3, 0x32d2, 0x4235, 0x5214, 0x6277, 0x7256,
        0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d,
        0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
        0xa7db, 0xb7fa, 0x8799, 0x97b8, 0xe75f, 0xf77e, 0xc71d, 0xd73c,
        0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634,
        0xd94c, 0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9, 0xb98a, 0xa9ab,
        0x5844, 0x4865, 0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882, 0x28a3,
        0xcb7d, 0xdb5c, 0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a,
        0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0, 0x2ab3, 0x3a92,
        0xfd2e, 0xed0f, 0xdd6c, 0xcd4d, 0xbdaa, 0xad8b, 0x9de8, 0x8dc9,
        0x7c26, 0x6c07, 0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1,
        0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9, 0x9ff8,
        0x6e17, 0x7e36, 0x4e55, 0x5e74, 0x2e93, 0x3eb2, 0x0ed1, 0x1ef0
      ];

      PACKET = {
        lead_code: [0xAA, 0xAA],
        head_code: 'SMARTCLOUD'
      }

      class Message
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
          msg_length = 0

          retrieve = false

          contents.each_with_index do |content, index|
            # detect [ ... 0xAA, 0xAA, ... ] presence inside the contents

            if !retrieve &&
                contents[index, PACKET[:lead_code].size ] == PACKET[:lead_code] &&
                contents[index + PACKET[:lead_code].size] != nil # can retrieve length

              msg_length = contents[index + PACKET[:lead_code].size]

              # check if given length is retrievable from contents
              if contents.size < (index + (PACKET[:lead_code].size - 1) + msg_length)
                clean_packet = contents.dup
                break # incomplete packet, msg_length exceeds contents size
              end

              retrieve = true # signal retrieving from current position if all is well
            end

            if retrieve
              if clean_packet.size < (msg_length + PACKET[:lead_code].size) # watch out for size of dat we are trying to retrieve, rest will be excess=
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
            if clean_packet.size == (msg_length + PACKET[:lead_code].size)
              fld_idx = PACKET[:lead_code].size
              message = Message.new(
                origin_subnet: clean_packet[fld_idx + 1],
                origin_device_id: clean_packet[fld_idx + 2],
                origin_device_type:  clean_packet[fld_idx + 3, 2],
                op_code: clean_packet[fld_idx + 5, 2],
                target_subnet:  clean_packet[fld_idx + 7],
                target_device_id:  clean_packet[fld_idx + 8],
                content:  clean_packet[fld_idx + 9..(clean_packet.size - 3)],
                crc: clean_packet[(clean_packet.size - 2), 2]
              )
            end
          end

          # return
          { message: message, excess: excess_packet, is_broken: message.nil? && clean_packet.any?, buffer: clean_packet }
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
          crc: nil )

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
