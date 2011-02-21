module Bio
  module NGS
    class NativeOptions
      
      attr_reader :task_name, :args
      # simple parsing from ARGV used to bypass Thor options parser and 
      # let the user call a tool with his own native set of parameters
      def initialize(arguments=ARGV)
          @task_name = arguments[0]
          @args = arguments[1..-1].flatten!
      end
      
    end
  end
end