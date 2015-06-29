module Matchers

  # If any email in the row matches any email in a previous row then the row is
  # marked with the same identifier as the previous row; otherwise a new
  # identifier is assigned.
  class EmailAnyPosition

    attr_accessor :identities

    def initialize
      @identities = Hash.new
      @identity = 0
    end

    def next_identity
      @identity += 1
    end

    # Email checking is very problematic but this should be OK for now.
    REGEXP_EMAIL = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i

    # Provides an identifier value for the row provided. The identifier
    # is an Fixnum value, starting at 1, and increments for each unique row
    # processed.
    # @param row [Array] the values of a CSV row.
    def identify row
      emails = select_all_emails(row)

      # If there are no emails in the row, simply return a new identifier
      # for the row.
      return next_identity if emails.empty?

      # Get all the row's emails that have an existing identifier, and return
      # the lowest number (this represents the first matching id).
      identifier = emails.map{|email| @identities[email]}.compact.min
      return identifier unless identifier.nil?

      identifier = next_identity
      emails.each{|email| @identities[email] = identifier}

      # return our new identifier
      identifier
    end

    def select_all_emails row
      row.select{|value|
        REGEXP_EMAIL =~ value
      }
    end
  end
end

