#
#  
#
# Copyright:: Copyright (C) 2011
#     Francesco Strozzi <francesco.strozzi@gmail.com>
# License:: The Ruby License
#
#

class History < Thor
  

  
  history = Bio::Ngs::Record.new(Bio::Ngs::HISTORY_FILE)
  
  history.load.each_with_index do |task,index|
    description = ""
    if task[:args].is_a?(Array)
       task[:args].each do |a|
         if a.is_a?(Hash)
           a.each_pair do |key,value|
            description << "#{key} => #{value} "
           end
         else
           description << a+" "
         end
       end   
    else
      description = task[:args]
    end
       
    # creating History tasks on the fly
    History.class_eval do
      desc (index+1).to_s,"Task #{task[:name]} PARAMETERS: #{description}"
      define_method (index+1).to_s.to_sym do
        if task[:args].size > 1
          invoke task[:name], [task[:args][0]], task[:args][1]
        else
          invoke task[:name], task[:args]
        end
      end
    end
  end
  
  desc "clear","Wipe out the tasks history"
  def clear
   history = Bio::Ngs::Record.new(Bio::Ngs::HISTORY_FILE)
   history.clear
  end

end