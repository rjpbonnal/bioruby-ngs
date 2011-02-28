# Opening Thor::Option, Thor::Arguments and Thor::Argument to define a :native options type.
# This is used for parameters sets that need to be passed directly to invoke a binary,
# without any Thor-like parsing.
class Thor
  
  class Option
    VALID_TYPES << :native
  end
    
  class Arguments
    
    def parse_native(name)
      array = []
      while peek # check if there are arguments left in the args array
        array << shift
      end  
      return array
    end
    
  end
  
  class Argument
    
    def default_banner
      case type
      when :boolean
        nil
      when :string, :default
        human_name.upcase
      when :numeric
        "N"
      when :hash
        "key:value"
      when :array
        "one two three"
      when :native
        " -use AS MANY -params AS --you-want"
      end
    end
    
  end
   
end