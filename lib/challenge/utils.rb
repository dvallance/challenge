class Utils

  class << self

    # memory is in Kilobytes
    def get_memory_usage
      begin
        `ps -o rss= -p #{Process.pid}`.to_i
      rescue
        0
      end
    end

    # Real quick method I threw in to get some stats displayed.
    def display_speed_and_memory_usage(file, matcher, &block)
      start_memory = get_memory_usage
      start_time = Time.now
      block.call()
      finished_time = Time.now - start_time
      finished_memory = get_memory_usage - start_memory
      puts ""
      puts "Processed: #{file}"
      puts "Matcher: #{matcher}"
      puts "Time(ms): #{finished_time.round(2)}"
      puts "Memory Usage(kb): #{finished_memory}"
      puts ""
    end
  end
end
