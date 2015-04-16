# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
require 'sax-machine'
require 'ce-greenbutton/elements/gb_content'
module GreenButton
  module Parser
    # a sax-machine mapping for the Entry structure
    #
    # For example:
    #   entry = GbEntry.parse(open(entry.xml))
    #
    #
    # Author: ahmed.seddiq
    # Version: 1.0
    class GbEntry
      include SAXMachine

      # The related entries. It is a hash {entry_type => entry_url}
      #   entry_urls are the href value of the link element with type "related"
      attr_accessor :related

      # The entry type, e.g. UsagePoint, IntervalBlock,...etc
      attr_accessor :type

      # Extract the href of the parent Entry
      element :link, as: :up, value: :href,  with: {rel: 'up'}

      # Extract the href of this Entry
      # The type is inferred from this href
      element :link, as: :self, value: :href,  with: {rel: 'self'} do |url|
        self.type = entry_type url
        url
      end

      # Extract the related Entries to the :related hash.
      elements :link, value: :href,  with: {rel: 'related'} do |url|
        if self.related.nil?
          self.related = {}
        end
        type = entry_type url
        unless type.nil?
          self.related[type] = url
        end
      end

      element :content, class: GbContent

      element :updated do |updated|
        DateTime.parse(updated).to_time
      end

      # Helper method to infer the entry type from the given url.
      #
      # url - the url
      #
      # Returns the entry type, e.g. UsagePoint, IntervalBlock,...etc
      private
      def entry_type(url)
        match = /\/(\w+)(\/(\d+))*$/.match(url)
        if match.nil?
          nil
        else
          match[1]
        end
      end

    end
  end
end
