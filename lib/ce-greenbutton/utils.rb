# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
require 'ice_cube'
require 'ce-greenbutton/ruby_extensions'
# Mixins for common functionality.
#
# Author: ahmed.seddiq
# Version: 1.0
#
module Utils
  module Hash
    # Converts instance variables of an object to a hash.
    #
    # obj - the object to inspect
    #
    # Returns a hash representing the instance variables of the given object.
    def to_hash
      if self.instance_variables.length > 0
        hash = {}
        self.instance_variables.each do |var|
          hash[var.to_s.delete('@')] = self.instance_variable_get(var)
        end
        hash
      else
        self
      end
    end
  end

  module DSTRule
    # Converts the given DST rule to a Time instance indicating the start
    # time of applying this rule.
    #
    # Based on the ESPI schema, The rule string is encoded as follows:
    #
    # Bits  0 - 11: seconds 0 - 3599
    # Bits 12 - 16: hours 0 - 23
    # Bits 17 - 19: day of the week 0 = not applicable, 1 - 7 (Monday = 1)
    # Bits:20 - 24: day of the month 0 = not applicable, 1 - 31
    # Bits: 25 - 27: operator  (detailed below)
    # Bits: 28 - 31: month 1 - 12
    #
    # Rule value of 0xFFFFFFFF means rule processing/DST correction is disabled.
    #
    # The operators:
    #
    # 0: DST starts/ends on the Day of the Month
    # 1: DST starts/ends on the Day of the Week that is on or after the Day of the Month
    # 2: DST starts/ends on the first occurrence of the Day of the Week in a month
    # 3: DST starts/ends on the second occurrence of the Day of the Week in a month
    # 4: DST starts/ends on the third occurrence of the Day of the Week in a month
    # 5: DST starts/ends on the forth occurrence of the Day of the Week in a month
    # 6: DST starts/ends on the fifth occurrence of the Day of the Week in a month
    # 7: DST starts/ends on the last occurrence of the Day of the Week in a month
    #
    # An example: DST starts on third Friday in March at 1:45 AM.  The rule...
    # Seconds: 2700
    # Hours: 1
    # Day of Week: 5
    # Day of Month: 0
    # Operator: 4
    # Month: 3
    #
    # rule - the dst rule, it can be the dst start rule or dst end rule.
    # Returns a Time instance representing the starting time of applying the rule
    #
    def to_time(rule)
      if rule.is_a? String
        # expected to be in hex
        rule = rule.to_i(16)
      end
      if rule == 0xFFFFFFFF
        return nil
      end

      parts = extract_parts(rule)

      # start a schedule with 1 January of current year
      current_year = DateTime.now.year
      end_of_year = Time.new(current_year, 12, 31,23,59,59)
      date = nil
      case parts[:operator]
        when 0
          raise InvalidDstRuleError, 'day of month must be provided for operator 0' if parts[:day_of_month] == 0
          date = Time.new(current_year, parts[:month], parts[:day_of_month])
        when 1
          raise InvalidDstRuleError, 'day of month must be provided for operator 1' if parts[:day_of_month] == 0
          raise InvalidDstRuleError, 'day of week must be provided for operator 1' if parts[:day_of_week] == 0
          # first day_of_week on or after the day of month
          schedule = IceCube::Schedule.new(Date.new(current_year, parts[:month], parts[:day_of_month]))
          # It may be in the next month
          months = [parts[:month], parts[:month] + 1]
          months = [parts[:month]] if parts[:month] == 12
          schedule.add_recurrence_rule IceCube::Rule.yearly.until(end_of_year).month_of_year(months).day_of_week(parts[:day_of_week] % 7 => [1, 2, 3, 4, 5])
          dates = schedule.all_occurrences
          raise InvalidDstRuleError, "Can't find day of week on or after the given day of month" if dates.length == 0
          date = dates[0]
        else
          raise InvalidDstRuleError, 'day of week must be provided for operators 2..7' if parts[:day_of_week] == 0
          # Last occurrence of day_of_week in the month
          order_in_month = parts[:operator] - 1
          order_in_month = -1 if (parts[:operator] == 7)
          schedule = IceCube::Schedule.new(Date.new(current_year, 1, 1))
          schedule.add_recurrence_rule IceCube::Rule.yearly.until(end_of_year).month_of_year(parts[:month]).day_of_week(parts[:day_of_week] % 7 => [order_in_month])
          dates = schedule.all_occurrences
          raise InvalidDstRuleError, "Can't find day of week on or after the given day of month" if dates.length == 0
          date = dates[0]
      end

      time = date.to_i
      time += (parts[:hours] * 60 * 60) + parts[:seconds]
      Time.at(time)
    end

    private
    def extract_parts(rule)
      parts = {}
      parts[:seconds] = rule.bits(from: 0, to: 11)
      parts[:hours] = rule.bits(from: 12, to: 16)
      parts[:day_of_week] = rule.bits(from: 17, to: 19)
      parts[:day_of_month] = rule.bits(from: 20, to: 24)
      parts[:operator] = rule.bits(from: 25, to: 27)
      parts[:month] = rule.bits(from: 28, to: 31)

      # validate extracted values
      raise InvalidDstRuleError, 'seconds should be from 0 - 3599' unless parts[:seconds] < 3600
      raise InvalidDstRuleError, 'hours should be from 0 - 23' unless parts[:hours] < 24
      raise InvalidDstRuleError, 'day_of_week should be from 0 - 7' unless parts[:day_of_week] < 8
      raise InvalidDstRuleError, 'day_of_month should be from 0 - 31' unless parts[:day_of_week] < 32
      raise InvalidDstRuleError, 'month should be from 1 - 12' unless parts[:month].between?(1, 12)
      parts
    end

    class InvalidDstRuleError < Exception
    end
  end
end