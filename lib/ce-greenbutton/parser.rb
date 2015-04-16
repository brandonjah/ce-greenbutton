# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
require 'ce-greenbutton/elements/gb_data_feed'
module GreenButton
  # Public: Defines a parse method. It accepts both strings and io inputs.
  #
  # Author ahmed.seddiq
  # Version: 1.0
  module Parser
    # Public: Parses the given input to an instance of GbDataFeed. After parsing
    # the GbDataFeed.entries will contain a hash of defined GbEntries. The key
    # of the hash is the "self" link identifies each entry. the "up" links are
    # also added to the hash with an array value aggregating all sub entries.
    #
    #
    # For example:
    #
    #   if we have a feed with one UsagePoint, one MeterReading, three IntervalBlocks
    #   the entries hash will be some thing like
    #   {"http://url.of.usage.point.self" => GbEntry(of type UsagePoint)}
    #   {"http://url.of.usage.point.up" => [GbEntry(of type UsagePoint)]}
    #   {"http://url.of.meter.reading.self" => GbEntry(of type MeterReading)}
    #   {"http://url.of.meter.reading.up" => [GbEntry(of type MeterReading)]}
    #   {"http://url.of.interval.block.1.self" => GbEntry(of type IntervalBlock)}
    #   {"http://url.of.interval.block.2.self" => GbEntry(of type IntervalBlock)}
    #   {"http://url.of.interval.block.3.self" => GbEntry(of type IntervalBlock)}
    #   {"http://url.of.interval.block.[1|2|3].up" =>
    #   [GbEntry(of type IntervalBlock), GbEntry(of type IntervalBlock),
    #   GbEntry(of type IntervalBlock)]
    #
    def self.parse(input)
      feed = Parser::GbDataFeed.parse(input)
      entries = {}
      feed.entries.each do |entry|
        # map self link to this entry
        entries[entry.self] = entry

        # add this entry to the up link

        # the "up" link will be the "self" link after removing the id part
        # if there is no id part in the "self" link, the "up" link is used.
        up_link = /(.*)\/\d+$/.match(entry.self)[1]
        up_link = entry.up if up_link.nil?

        if entries[up_link].nil?
          entries[up_link] = []
        end
        entries[up_link] << entry
        entry.link = nil
      end

      feed.entries = entries
      feed
    end

  end


end





