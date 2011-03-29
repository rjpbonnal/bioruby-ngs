#
#  wrapper.rb - Wrapper class for a generic command
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#

require 'bio'

#Notes
# in case you are developing a new wrapper and want to have a secure environment
# you must not define the program name and the task will not be cerated.


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

      # Return the options and parameters formmatted as typed in the command line as a string
      # TODO: need to be compliant with Bio::Command ?
      # TODO: make a test because it should not return an empty string.
      # TODO: refactor is not beauty
      def normalize_params
        args=params.to_a.map do |option|
          option_name = option[0]
          option_values = option[1]
          if option_values.kind_of? Hash
            #TODO: refactor this code and verify that the boolean needs a specific options setting.
            #"--#{option_name}" + ((option_values.has_key?(:type) && option_values[:type]==:boolean) ? ("="+ (option_values[:default] ? "true": "false")) :"=#{option_values[:default]}")
            if (option_values.has_key?(:type) && option_values[:type]==:boolean && option_values[:default])
              "--#{option_name}"
            else
              "--#{option_name}=#{option_values[:default]}"
            end
          else #is a value of the main hash. (mostly a parameter)
            if option_values == true
              "--#{option_name}"
            elsif option_values != false
              "--#{option_name}=#{option_values}"
            end
          end
        end
        args.empty? ? []  : args.join(" ")
      end

      def output
        self.class.output || :file
      end


      # If parameters are passed they will overwrite those already defined
      # but will not save the changes
      # opts = {:options=>{}, :arguments=>[]}
      # in the particular case the user wants to submit other options
      # these must be passed in arguments like {"option_name"=>value} similar when settin params
      # TODO handle output file with program which writes on stdout
      #TODO: refactor mostly due to stdin/out
      def run(opts = {:options=>{}, :arguments=>[], :output_file=>nil})
        if program.nil?
          warn "WARNING: no program is associated with #{class_name.upcase} task."
          return nil
        end  
        #REMOVE        params = opts[:options]
        if output == :stdout 
          raise "Can't write to any output file. With a program which writes on stdout you must provide a file name" if opts[:output_file].nil?
          file_stdlog = File.open(opts[:output_file], 'w')
          file_errlog = File.open(opts[:output_file]+".err",'w')

          Bio::Command.call_command_open3([program, normalize_params, opts[:arguments]].flatten) do |pin, pout, perr|
            pout.sync = true
            perr.sync = true           
            t = Thread.start {pout.lines{|line| file_stdlog.puts line}}
            begin
              pin.close
            ensure
              t.join
            end
          end #command call open3
          file_stdlog.close
          file_errlog.close
        else
#          puts [program, normalize_params, opts[:arguments]].flatten
          Bio::Command.query_command [program, normalize_params, opts[:arguments]].flatten
        end #if
      end #run

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
        if program.nil?
          warn "WARNING: no program is associated with #{class_name.upcase} task, does not make sense to create a thor task."
          return nil
        end          
        if klass
          wrapper = self   
          klass.class_eval do            
            wrapper.options.each_pair do |name, opt|
              method_option name, opt
            end #each_pair
            # Thor's behavior should be respected passing attributes
            define_method task_name do |*args|
              #it's mandatory that the first and second parameter are respectively wrapper and task
              raise ArgumentError, "wrong number of arguments (#{args.size} for #{block.parameters.size-2})" if args.size != block.parameters.size-2
              yield wrapper, self, *args
            end
          end#class_eval
        end #klass
      end #thor_task

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

        OUTPUT = [:file, :stdout, :stdin]

        # output = {:file=>true, :stdout=>}
        attr_accessor :output

        #TODO I don't like this way, Is it possible to configure the variable as global and default ?
        def set_output(output_type=:file)
          if OUTPUT.include? output_type
            @output = output_type
          else
            raise "Output type #{output_type} is not suported. Valid types are #{OUTPUT}"
          end
        end

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
