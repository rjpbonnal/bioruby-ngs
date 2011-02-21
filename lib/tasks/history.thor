class History < Thor
  
  # creating History tasks on the fly
  @@num = 1
  Bio::NGS::Record.load.each do |task|
    History.class_eval do
      desc @@num.to_s,"Task #{task[:name]} #{task[:args]}"
      define_method @@num.to_s.to_sym do
        # set ARGV to mimick command line invocation
        ARGV[0] = task[:name]
        ARGV[1] = task[:args]
        invoke task[:name], [task[:args][0]], task[:args][1]
      end
    end
    @@num += 1
  end
  
  desc "clear","wipe out the tasks history"
  def clear
    Bio::NGS::Record.clear
  end

end