module Bio
  module NGS  
    class Record
      
      require 'yaml'
      def self.save(name,*args)
        params = {:name => name, :args => args }
        unless saved?(params) || params[:name] =~/history/
          history = File.new(".task-history.yml","a") 
          history.write(params.to_yaml)
          history.close
        end
      end
      
      def self.load
        begin
          history = File.open(".task-history.yml")
        rescue
          return {}
        else    
          tasks = []
          YAML.each_document(history) do |ydoc| 
            ydoc[:args].flatten!
            tasks << ydoc
          end
          return tasks
        end  
      end
      
      def self.clear
        history = File.open(".task-history.yml","w")
        history.close
      end
      
      private
      
      def self.saved?(params)
        begin
          history = File.open(".task-history.yml")
        rescue
          return false
        else      
          tasks = []
          YAML.each_document(history) {|ydoc| tasks << ydoc}
          return tasks.include?(params) 
        end
      end
      
    end
  end
end