module Bio
  module Command
    module Wrapper


      def self.included(base)
        base.extend(ClassMethods)
      end
      
      def options
        self.class.options
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
# 
# module Bio
# module Command
#   class Wrapper
#     attr_accessor :parameters
#     def initialize
#       # parameters is an hash with the name of the parameter and an array of valid attributes,
#       # parameters' name are without --
#       # valid attributes are :default, :type, :alias, :required
#       @options=Hash.new
#     end
#     
#     # external_parameter can be an array a string or an hash
#     # def validate_parameters(external_parameters)
#     def self.add_parameter(name, opt={})
#       @parameters.merge!(name=>opt)
#     end
#   end #Wrapper
# end #Command
# end #Bio