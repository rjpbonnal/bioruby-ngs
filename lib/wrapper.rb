#
#  wrapper.rb - Wrapper class for a generic command
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#

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
        #convert all keys symbols in strings
        option = option.inject({}){|h,item| h[item[0].to_s]=item[1]; h}
        @options.merge!(option)
      end

      def program
        @program
      end
      
      def sub_program
        self.class.sub_program
      end

      def initialize(binary=nil, options={})
        @program = binary || self.class.program
        @options = options
        @params = {}
        @pipe_ahead = []
        @path = options.delete(:path) || "."
      end

      def path
        @path
      end

      def path=(path)
        @path=path
      end

      # Parameters are accepted ONLY if the key is present as
      # a key on the options hash. Sort of validation.
      # ONLY the valid options are taken into account.
      # It like a third level of configuration
      #TODO: check :aliases in options as well, not that now only the main option name is verified
      def params=(opts={})
        #add the parameters only if in options
        opts.each_pair do |parameter, value|
          @params[parameter.to_s] = value if options.has_key?(parameter.to_s)
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


      def pipe_ahead
        # TODO: recursive call to other Bio::Ngs wrapped commands
        @pipe_ahead
      end

      def pipe_ahead?
        return !@pipe_ahead.empty?
      end

      # If setted is an array described like the ones in Open3.pipeline
      # http://www.ruby-doc.org/stdlib-1.9.3/libdoc/open3/rdoc/Open3.html#method-c-pipeline
      def pipe_ahead=(ary)
        @pipe_ahead=ary || []
      end

      #Return an array of elements of the command line
      def to_cmd_ary(opts={arguments:[],separator:"="})
      #  [program, sub_program, normalize_params(opts[:separator]), opts[:arguments]].flatten.compact
      [program, sub_program, normalize_params(opts[:separator]), opts[:arguments].map{|a| a.split}].flatten.compact
      end

      # Return the options and parameters formmatted as typed in the command line as a string
      # opts[:separator] is important not all the applications require a "=" for separating options and values
      # TODO: need to be compliant with Bio::Command ?
      # TODO: make a test because it should not return an empty string.
      # TODO: refactor is not beauty
      def normalize_params(separator="=")
        #use_aliases?
        args=params.to_a.map do |option|
          option_name = option[0].to_s
          option_values = option[1]
          #deprecated I'm not sure this code is good (at least the one with kind_of?)
          if option_values.kind_of? Hash
            #TODO: refactor this code and verify that the boolean needs a specific options setting.
            #"--#{option_name}" + ((option_values.has_key?(:type) && option_values[:type]==:boolean) ? ("="+ (option_values[:default] ? "true": "false")) :"=#{option_values[:default]}")
            if (option_values.has_key?(:type) && option_values[:type]==:boolean && option_values[:default])
              "--#{option_name}"
            else
              use_aliases? && options[option_name].has_key?(:aliases) ? '#{options[option_name][:aliases]}#{option_values[:default]}' : "--#{option_name}#{separator}#{option_values[:default]}"
            end
            #deprecated up to here
          else #is a value of the main hash. (mostly a parameter)
            if option_values == true
              use_aliases? && options[option_name].has_key?(:aliases) ? options[option_name][:aliases] : "--#{option_name}"
            elsif option_values != false
              use_aliases? && options[option_name].has_key?(:aliases) ? "#{options[option_name][:aliases]}#{options[option_name][:collapse] ? "": ''}#{option_values}" : "--#{option_name}#{separator}#{option_values}"
            end
          end
        end
      end

      def output
        self.class.output || :file
      end

      def use_aliases?
        self.class.aliases
      end


      # If parameters are passed they will overwrite those already defined
      # but will not save the changes
      # opts = {:options=>{}, :arguments=>[]}
      # in the particular case the user wants to submit other options
      # these must be passed in arguments like {"option_name"=>value} similar when settin params
      # opts[:separator] is important not all the applications require a "=" for separating options and values
      # TODO handle output file with program which writes on stdout
      #TODO: refactor mostly due to stdin/out
      def run(opts = {:options=>{}, :arguments=>[], :output_file=>nil, :separator=>"="})
        if program.nil?
          warn "WARNING:run: no program is associated with #{class_name.upcase} task." if Bio::Ngs::Utils.verbose?
          return nil
        end  
        #REMOVE        params = opts[:options]
        if output == :stdout 
          raise "Can't write to any output file. With a program which writes on stdout you must provide a file name" if opts[:output_file].nil?
          file_stdlog = File.open(opts[:output_file], 'w')
          file_errlog = File.open(opts[:output_file]+".err",'w')
          #[program, sub_program, normalize_params(opts[:separator]), opts[:arguments]].flatten.compact
          Bio::Command.call_command_open3(to_cmd_ary(separator:opts[:separator], arguments:opts[:arguments])) do |pin, pout, perr|
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

        elsif pipe_ahead?
          #in case the user setted the pipeline we use it.
          Open3.pipeline(pipe_ahead, to_cmd_ary(separator:opts[:separator], arguments:opts[:arguments]))
        else
          # puts "Normlized #{normalize_params(opts[:separator])}"
          # puts "Arguments #{opts[:arguments]}"
          # puts [program, sub_program, normalize_params(opts[:separator]), opts[:arguments].map{|x| x.split}]
          #puts to_cmd_ary(separator:opts[:separator], arguments:opts[:arguments])
          # .flatten.compact.inspect
        #Note: maybe seprator could be defined as a method  for each wrapped program ?
        #Bio::Command.query_command(to_cmd_ary(separator:opts[:separator], arguments:opts[:arguments]))
        cmd = to_cmd_ary(separator:opts[:separator], arguments:opts[:arguments]).flatten
        puts cmd.inspect
        system(*cmd)
        #[program, sub_program, normalize_params(opts[:separator]), opts[:arguments]].flatten.compact
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
          warn "WARNING:thor_task: no program is associated with #{class_name.upcase} task, does not make sense to create a thor task."  if Bio::Ngs::Utils.verbose?
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

      #Return the class name
      def class_name
        self.class.name.split("::").last.downcase
      end

      module ClassMethods

        # Propagate class variable in the superclass to the inherited class,
        # so options defined in a previous wrap can be recicled.
        def inherited(subclass)
          self.instance_variables.each do |var|
            subclass.instance_variable_set(var, self.instance_variable_get(var))
          end
        end

        #TODO: do I need to set a default program name using class name or not ?
        #       or do we need to specify somewhere a defaitl path and looking for a real binary ?

        OUTPUT = [:file, :stdout, :stdin]

        # output = {:file=>true, :stdout=>}
        attr_accessor :output, :program, :options, :aliases, :sub_program

        #TODO I don't like this way, Is it possible to configure the variable as global and default ?
        def set_output(output_type=:file)
          if OUTPUT.include? output_type
            @output = output_type
          else
            raise "Output type #{output_type} is not suported. Valid types are #{OUTPUT}"
          end
        end

        def use_aliases
          @aliases = true
        end

        # external_parameter can be an array a string or an hash
        # def validate_parameters(external_parameters)
        def add_option(name, opt={})
          @options = (@options || {}).merge(name.to_s=>opt)
        end

        # Remove an option from the class
        def delete_option(name)
          @options.delete(name)
        end

        # An alias reuse the properties of a specific method and giving them another name
        # def add_alias(source, dest)
        #   @options = (@options || {}).merge(name.to_s=>@options[dest.to_s]) unless @options[dest]
        # end

        alias set_program program=
        alias set_sub_program sub_program=

      end #ClassMethods

    end #Wrapper
  end #Command
end #Bio
