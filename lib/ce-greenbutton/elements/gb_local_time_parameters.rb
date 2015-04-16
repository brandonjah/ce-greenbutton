# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.

require 'sax-machine'
require 'ce-greenbutton/utils'

module GreenButton
  module Parser
    # a sax-machine mapping for the espi:LocalTimeParameters structure
    #
    # For example:
    #   local_time_parameters = GbLocalTimeParameters.parse(open(local_time_parameters.xml))
    #
    #
    # Author: ahmed.seddiq
    # Version: 1.0
    class GbLocalTimeParameters
      include SAXMachine
      include Utils::DSTRule

      attr_accessor :dst_start_time
      attr_accessor :dst_end_time
      attr_accessor :tz_offset

      # an instance representing the EDT timezone
      EDT = GbLocalTimeParameters.new(tz_offset: -14400)

      # Elements with "espi" namespace
      element :'espi:dstEndRule', as: :dst_end_rule do |rule|
        @dst_end_time = to_time(rule)
        rule
      end
      element :'espi:dstStartRule', as: :dst_start_rule do |rule|
        @dst_start_time = to_time(rule)
        rule
      end
      element :'espi:dstOffset', class: Integer, as: :dst_offset
      element :'espi:tzOffset', class: Integer, as: :tz_offset


      # Elements without namespace
      element :dstEndRule, as: :dst_end_rule do |rule|
        @dst_end_time = to_time(rule)
        rule
      end
      element :dstStartRule, as: :dst_start_rule do |rule|
        @dst_start_time = to_time(rule)
        rule
      end
      element :dstOffset, class: Integer, as: :dst_offset
      element :tzOffset, class: Integer, as: :tz_offset

      # Converts time to local based on the given time configuration.
      #
      # The time after applying the rules in the time_config
      #
      def local_time(time)
        # apply timezone offset
        time += self.tz_offset
        # apply dst offset
        unless @dst_start_time.nil? or @dst_end_time.nil?
          if Time.now.between?(@dst_start_time, @dst_end_time)
            time += self.dst_offset
          end
        end
        Time.at(time)
      end
    end

  end
end
