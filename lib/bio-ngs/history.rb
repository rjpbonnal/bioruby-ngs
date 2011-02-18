module Bio
  module NGS
    
    class History
      require 'yaml'
      def self.save(name,*args)
        history = File.new(".task-history.yml","a")
        history.write(([name]+args).to_yaml)
      end
      
      def self.load
        # to do
      end
      
    end
    
  end
end