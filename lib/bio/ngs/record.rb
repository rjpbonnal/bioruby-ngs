#
#  
#
# Copyright:: Copyright (C) 2011
#     Francesco Strozzi <francesco.strozzi@gmail.com>
# License:: The Ruby License
#
#

module Bio
  module Ngs
    class Record
      
      require 'yaml'  
      
      def initialize(file)
        @filename = file
        @file = File.new(file,"a+")
      end
    
      def save(name,*args)
        params = {:name => name, :args => args }
        unless is_saved?(params) || params[:name] =~/history/
          @file.write(params.to_yaml)
          @file.close
        end
      end
      
      def load   
          tasks = []
          YAML.each_document(@file) do |ydoc| 
            ydoc[:args].flatten!
            tasks << ydoc
          end
          return tasks
      end
      
      def clear
        history = File.delete(@filename)
      end
      
      private
      
      def is_saved?(params)    
          tasks = []
          YAML.each_document(@file) {|ydoc| tasks << ydoc}
          return tasks.include?(params)
      end
      
    end
  end
end