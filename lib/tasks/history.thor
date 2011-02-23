class History < Thor
  
  # creating History tasks on the fly
  @@num = 1
  Bio::NGS::Record.load.each do |task|
    
    description = ""
    if task[:args].is_a?(Array)
       task[:args].each do |a|
         if a.is_a?(Hash)
           a.each_pair {|key,value| description << "#{key} => #{value}, "}
         else
           description << a+", "
         end
       end   
    else
      description = task[:args]
    end

    History.class_eval do
      desc @@num.to_s,"Task #{task[:name]} PARAMETERS: #{description}"
      define_method @@num.to_s.to_sym do
        if task[:args].size > 1
          invoke task[:name], [task[:args][0]], task[:args][1]
        else
          invoke task[:name], task[:args]
        end
      end
    end
    @@num += 1
  end
  
  desc "clear","Wipe out the tasks history"
  def clear
    Bio::NGS::Record.clear
  end

end