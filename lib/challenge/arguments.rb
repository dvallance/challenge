require 'singleton'

# Handles all arguments passed into the applicaiton.
class Arguments
  include Singleton

  attr_accessor :input, :output, :matcher

  # A short message on how to call the real help display.
  def help_message
    "For help use the -h option (e.g., #{$PROGRAM_NAME} -h)"
  end

  # Validate our arguments.
  # @raise [ArgumentError] raised if there are any argument issues that would
  #   prevent the application from running.
  def verify!
    # Do we have a CSV file to work with?
    raise ArgumentError, "Please provide a valid CSV file with the [-i or --input] option." if input.nil? || !File.exists?(input)
  end

  def self.parse args
    parser = OptionParser.new do |p|
      p.separator ""
      p.banner = "Usage: #{$PROGRAM_NAME} [options] $FILE_PATH"
      p.separator "Where $FILE_PATH should be the path to an existing CSV file."
      p.separator ""
      p.separator "Available options:"

      p.on_tail("-h", "--help", "Display this help message.") do
        puts p.help
        exit! 0
      end

      p.on_tail("-v", "--version", "Show version information.") do
        puts "#{p.program_name} #{Challenge::VERSION}"
        exit! 0
      end

      p.on("-o", "--output CSV", "Output indentified CSV to a file. (By default the CSV will to output to the console).") do |setting|
        Arguments.instance.output = setting
      end

      #TODO load the available matchers dynamically (for now hardcode)
      p.on("-m", "--matcher MATCHER", ["RowEquality", "EmailAnyPosition", "EmailSamePosition"], "Specify a specific matcher to use. (By default the RowEquality matcher will be used.)") do |setting|
        Arguments.instance.matcher = setting
      end
    end

    begin
      parser.parse!(args)
      Arguments.instance.input = args[0]
      Arguments.instance.verify!
    rescue Exception => e
      puts "#{e.message}"
      # The full help message is a little verbose to always display.
      puts Arguments.instance.help_message
      exit! 1
    end
  end
end
