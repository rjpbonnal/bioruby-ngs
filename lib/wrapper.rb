module Bio
  module Command
    module Wrapper


      def self.included(base)
        base.extend(ClassMethods)
      end
      
      def options
        @options || self.class.options
      end

      def program
        @program || self.class.program
      end

      module ClassMethods
        @@options = Hash.new
        @@program = ""
        
        def options
          @@options
        end

        # external_parameter can be an array a string or an hash
        # def validate_parameters(external_parameters)
        def add_option(name, opt={})
          options.merge!(name=>opt)
        end
        
        def set_program(path)
          @@program = path
        end
        
        def program
          @@program
        end
        
      end #ClassMethods

    end #Wrapper
  end #Command
end #Bio
