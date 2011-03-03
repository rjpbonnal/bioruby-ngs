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

      # def dynamic_task(tasks, name=nil, desc=nil)
      #   task = Thor::DynamicTask.new(name || class_name)
      #   task.options = options
      #   tasks[task.name] = task
      #   task
      #   #Thor::DynamicTask.new('task').description.should == 'A dynamically-generated task'
      #   #Thor::DynamicTask.new('task').usage.should == 'task'
      #   #Thor::DynamicTask.new('task').options.should == {}      
      # end


      # Inject into the Thor::Sandbox::TaskName the options defined for this 
      # wrapper
      def thor_task(klass, task_name, &block)
        if klass
          options.each_pair do |name, opt|
            klass.method_option name, opt
          end #each_pait
          instance = self   
          klass.class_eval do
            define_method(task_name) do
              yield instance
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
