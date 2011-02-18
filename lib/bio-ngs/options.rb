module Bio
  module NGS
    class Options
      
      # simple parsing from ARGV to bypass Thor options parsing and 
      # let the user call a tool with his own native set of parameters
      def self.use_native_options
        return  ARGV[0], ARGV.slice(1..-1) 
      end
      
    end
  end
end