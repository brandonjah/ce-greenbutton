# Copyright (C) 2015 TopCoder Inc., All Rights Reserved.

# Extending the Integer to add the utility method of extracting bits
class Integer
  # Extracts bits in range from: to to:
  #
  # Example:
  #   10.bits(from:1, to:2)   # 1010
  #   # => 1
  def bits(options)
    from = options[:from] || 0
    to = options[:to]
    val = self
    unless from.nil?
      val = val >> from
    end
    unless to.nil?
      val = val & (2 ** (to - from + 1) - 1)
    end

    val
  end
end