module Matchers

  # A simple matcher that identifies duplicate rows.
  class RowEquality

    attr_accessor :identities

    def initialize
      @identities = Hash.new
      @identity = 0
    end

    def next_identity
      @identity += 1
    end

    # Provides an identifier value for the row provided. The identifier
    # is an Fixnum value, starting at 1, and increments for each unique row
    # processed.
    # @param row [Array] the values of a CSV row.
    def identify row
      # hash the row to provide a usefull key
      hash = row.hash

      # find an existing identity or create one with next_identity
      @identities[row.hash] || (@identities[hash] = next_identity)
    end

  end
end
