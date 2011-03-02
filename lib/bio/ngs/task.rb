# opening class Thor::Task to add a save_history method
class Thor
  class Task

    def run(instance, args=[])
      public_method?(instance) ? instance.send(name, *args) : instance.class.handle_no_task_error(name)
      save_history(instance,args) unless instance.class == Bio::Ngs::Runner or instance.class == Thor::Sandbox::History
    rescue ArgumentError => e
      handle_argument_error?(instance, e, caller) ?
      instance.class.handle_argument_error(self, e) : (raise e)
    rescue NoMethodError => e
      handle_no_method_error?(instance, e, caller) ?
      instance.class.handle_no_task_error(name) : (raise e)
    end
    
    
    private
    
    # process Thor instance and save the task name and parameters
    def save_history(instance,args)
      invocation =  instance.instance_variable_get("@_invocations").to_a[0]
      classes = invocation[0].to_s
      name = invocation[1].first
      classes.gsub!(/Thor::Sandbox::/,"")
      classes.gsub!(/::/,":")
      classes.downcase!
      options = [args,instance.options]
      history = Bio::Ngs::Record.new(Bio::Ngs::HISTORY_FILE)
      history.save(classes+":"+name,options)
    end
    
    
  end
end