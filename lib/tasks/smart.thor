

# require 'bio-ngs'
# require 'securerandom'
# require 'thor'
 require 'fileutils'
# require 'yaml'
# require 'parallel'

# Example of call using nohup for tracking output
# nohup time /mnt/bio/ngs/data/bin/oases_fastq_processing.rb oases /mnt/bio/ngs/data/LandscapeBioNGS Naive --exclude_samples "SQ_0040:SQ_0041:SQ_0042:SQ_0043:SQ_0044:SQ_0045:SQ_0110:SQ_0112" --insertion_length 380 > nohup_Naive.out 2>&1&

class Smart < Thor

#note some parameters are hardcoded like skipped SAMPLEs and excluded path
#todo: generalize 
  desc "data CRITERIA", "from NGS dataset perform an OASES assembly on a specific project"
  method_option :root, :type => :string, :default => './'
  method_option :rescan, :type => :boolean, :desc => 'rescan the directory'
  #method_option :criteria, :type => :string, :desc => 'returns file following a sort of sets criteria "-:rtf:SQ_0040:SQ_0041:SQ_0042:SQ_0043:SQ_0044:SQ_0045:SQ_0110:SQ_0112"'
  #method_option :exclude_samples, :type => :string, :desc => 'list of samples separated by semicolumns'
  #method_option :insertion_length, :type => :numeric, :desc => 'insertion length 2 for oases'
  def data(*criteria)
    smart = {}
    smart_data_filename = File.join(options[:root], "conf", "smart.dump")


    if File.exists?(smart_data_filename) && !options[:rescan]

      File.open(smart_data_filename,'r') do |f|
        smart = Marshal.load(f)
      end
    else
      smart[:raw] = Bio::Ngs::FS::Project.discover(options[:root], :excludes=>[/annotation/,/log/,/MAPQUANT_Projects/, /PhiX/, /Temp/])
      #generazione dell’indice
      FileUtils.mkdir_p(File.dirname(smart_data_filename)) #check is exists or not the directory and in negative case, it creates       
      File.open(smart_data_filename,'w') do |f|
        Marshal.dump(smart, f)
      end
    end

    smart[:index] = Bio::Ngs::FS::Project.index(smart[:raw])
     

    #lista dei progetti, qui e’ stato eliminato il PhiX, dalla discovery precedente
    #Bio::Ngs::FS::Project.search(i, project ).each do |project|
    Bio::Ngs::FS::Project.search(smart[:index], *criteria).each do |result|
     puts File.join(options[:root],result.to_s)
    end

  end #data

end #Smart
