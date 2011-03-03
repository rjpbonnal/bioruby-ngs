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

      def initialize(program=nil, options={})
        @program = program
        @options = options
      end

      # Inject into the Thor::Sandbox::TaskName the options defined for this 
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
