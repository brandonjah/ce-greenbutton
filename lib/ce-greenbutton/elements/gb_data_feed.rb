# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
require 'sax-machine'
require 'ce-greenbutton/elements/gb_entry'

module GreenButton
  module Parser
    # a sax-machine mapping for the espi:DataFeed structure
    #
    # For example:
    #   data_feed = GbDataFeed.parse(open(data_feed.xml))
    #
    #
    # Author: ahmed.seddiq
    # Version: 1.0
    class GbDataFeed
      include SAXMachine
      elements :entry, class: GbEntry, as: :entries

      # Get the related entry to the given entry of the given type
      #
      # entry - the parent entry.
      # type  - the type of the required entry,e.g. 'MeterReading'
      #
      # Note: This method should be only called on instances returned from Parser.parse
      # method.
      #
      # Returns the related GbEntry
      def get_related (entry, type)
        related_entry_key = entry.related[type] unless entry.related.nil?
        self.entries[related_entry_key]
      end
    end
  end
end
