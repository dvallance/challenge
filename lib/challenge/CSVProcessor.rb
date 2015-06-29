# Responsible for reading through a CSV file, sending the rows to a
# matcher (e.g., #{Matchers::RowEquality}), and outputing the results.
class CSVProcessor

  class << self

    # Determines the matcher Class to use.
    # @param matcher [String or NilClass] will map to a matcher class or in the case
    #   of nil the default #{Matchers::RowEquality} matcher will be used.
    def determine_matcher matcher
      # TODO make the lookup smarter. (this is ok for now)
      # For now simply use a default.
      return Matchers::RowEquality.new if matcher.nil?
      Object.const_get("Matchers::#{matcher}").new
    end

    # Determines the output method of the program.
    # @param output [String or NilClass] will write to a file or to stdout in the
    #   case of nil.
    # @param headers [Array] when provide headers will be written.
    def determine_output output, headers=nil
      if output.nil?
        opts = [STDOUT] # $stdout
        opts = opts + [write_headers: true, headers: headers] if headers
        CSV(*opts)
      else
        opts = [output, "wb"]
        opts = opts + [write_headers: true, headers: headers] if headers
        CSV.open(*opts)
      end
    end

    # @param input [String] CSV file path.
    # @param output [String] file path for writing (nil results in outputting to
    #   stdout)
    # @param matcher [String] maps to a matcher class. Responsible for marking
    # the generated CSV file with an Identifier column.
    def run(input:, output: nil, matcher: nil)
      begin
        matcher = determine_matcher(matcher)

        # Open our two csv files.
        csv_in = CSV.open(input, headers: true)

        # Handle adding Identifier to headers.
        # TODO there must be a better way to get the headers other then
        # doing a readline and then a rewind to avoid losing a row.
        headers = nil
        if csv_in.header_row?
          headers = ["Identifier"] + csv_in.readline.headers
          csv_in.rewind
        end

        out = determine_output(output, headers)
        csv_in_enumerator = csv_in.each
        csv_in_enumerator.each do |row|
          row_values = row.fields
          identifier = matcher.identify(row_values)
          out << row_values.unshift(identifier)
        end

      rescue Exception => e
        puts "There was an error: #{e.message}"

      ensure
        csv_in.close unless csv_in.closed?
        out.close unless out.closed?
      end
    end
  end
end
