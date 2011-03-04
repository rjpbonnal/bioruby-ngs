#
#  wrapper.rb - Wrapper class for a generic command
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#



module Bio
  module Command
    module Wrapper

      def self.included(base)
        base.extend(ClassMethods)
      end

      def options
        self.class.options.merge(@options)
      end

      def options=(option={})
        @options.merge!(option)
      end

      def program
        @program || self.class.program
      end

      def initialize(binary=nil, options={})
        @program = binary || program
        @options = options
        @params = {}
      end
            
      # Parameters are accepted ONLY if the key is present as
      # a key on the options hash. Sort of validation.
      # ONLY the valid options are taken into account.
      # It like a third level of configuration
      def params=(opts={})
        #add the parameters only if in options
        opts.each_pair do |parameter, value|
          @params[parameter] = value if options.has_key? parameter
        end        
      end
      
      def default_options
        options.select do |name, opts|
          opts.has_key? :default
        end
      end
            
      # Return the options, which are by default, and the parameters
      # setted by the user.
      # Precedence goes to params setted from user
      def params
        default_options.merge(@params)
      end
      
      def reset_params
        @params.clear
      end
      
      # Return the options and parameters formmatted as typed in the command line.
      # TODO: need to be compliant with Bio::Command ?
      def normalize_params
        params.to_a.map do |option|
          option_name = option[0]
          option_values = option[1]
          if option_values.kind_of? Hash
            "--#{option_name}" + ((option_values.has_key?(:type) && option_values[:type]==:boolean) ? ("="+ (option_values[:default] ? "true": "false")) :"=#{option_values[:default]}")
          else #is a value of the main hash. (mostly a parameter)
            "--#{option_name}=#{option_values}"
          end
        end.join(" ")
      end
      
      # If parameters are passed they will overwrite those already defined
      # but will not save the changes
      # opts = {:options=>{}, :arguments=>[]}
      # in the particular case the user wants to submit other options
      # these must be passed like {"option_name"=>value} similar when settin params
      def run(opts = {:options=>{}, :arguments=>[]})
        params = opts[:options]
        Bio::Command.query_command [program, normalize_params] + opts[:arguments]
      end

      # Inject into the Thor::Sandbox::TaskName (klass) the options defined for this 
      # wrapper
      # Example of call
      #   desc "task_name ARG_ONE ARG_SECOND", "run tophat as from command line"
      #   Bio::Ngs::Tophat.new.thor_task(self, :tophat) do |wrapper, task, ARG_ONE ARG_SECOND|
      #       puts ARG_ONE
      #       puts ARG_SECOND
      #       #you tasks here
      #   end      
      def thor_task(klass, task_name, &block)
        if klass
          wrapper = self   
          klass.class_eval do            
            wrapper.options.each_pair do |name, opt|
               method_option name, opt
             end #each_pair

            # Thor's behavior should be respected passing attributes            
            define_method(task_name) do |*args|
              yield wrapper, self, args
            end #define_method
          end#class_eval
        end
      end

      def thor_test(klass, name)
        puts klass.inspect
        puts klass.options.inspect1
      end

      #Return the class name
      def class_name
        self.class.name.split("::").last.downcase
      end

      module ClassMethods
#TODO: do I need to set a default program name using class name or not ?
#       or do we need to specify somewhere a defaitl path and looking for a real binary ?

        attr_accessor :program, :options

        # external_parameter can be an array a string or an hash
        # def validate_parameters(external_parameters)
        def add_option(name, opt={})
          @options = (@options || {}).merge(name=>opt)
        end

        alias set_program program=

      end #ClassMethods

    end #Wrapper
  end #Command
end #Bio
