#
#  convert.thor - Main task for converting data between NGS formats
#
# Copyright:: Copyright (C) 2011
#     Raoul J.P. Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#


#TODO: Usare i name spaces per suddividere le conversioni, così non mi piacciono
#TODO: biongs convert:qseq:fastq
module Convert
  module Qseq
    class Fastq < Thor
      desc "by_file FIRST OUTPUT", "Convert a qseq file into fastq"
      method_option :paired, :type => :boolean, :default => false, :desc => 'Convert the reads in the paired format'
      method_option :append, :type => :boolean, :default => false, :desc => 'Append this convertion to the output file if exists'
      # output is just a string I'll attach the fastq extension
      def by_file(first, output)
        qseq = Bio::Ngs::Converter::Qseq.new(:pe)
        qseq.buffer = File.open(first,'r')
        fastq_file = File.open("#{output}.fastq", (options.append ? 'w' : 'a'))
        qseq.to_fastq(options.paired ? :pe : :se) do |fastq|
          fastq_file.puts fastq if fastq
        end
        fastq_file.close
      end #qseq_to_fastq

      desc "by_lane LANE OUTPUT", "Convert all the file in the current and descendant directories belonging to the specified lane in fastq. This command is specific for Illumina qseqs file s_#LANE_#STRAND_#TILE. Note UNKOWN directory is excluded by default."
      method_option :paired, :type => :boolean, :default => false, :desc => 'Convert the reads in the paired format searching in the directories.'
      # output is just a string I'll attach the fastq extension
      def by_lane(lane, output)

      end #qseq_to_fastq_by_lane
    end #Fastq
  end #Qseq

  module Bcl 
    class Qseq < Thor
    desc "convert RUN OUTPUT [JOBS]", "Convert a bcl dataset in qseq"
    def converts (run_basecalls_root, output, jobs=1)
      invoke :configure_conversion, [run_basecalls_root, output]
      invoke :run_bcl_to_qseq, [run_basecalls_root, jobs]
    end #bcl_to_qseq

    desc "configure_conversion RUN_DIR OUTPUT ", "Configure the specific Run to be converted", :hide => true
    Bio::Ngs::Bclqseq.new.thor_task(self, :configure_conversion) do |wrapper, task, run_basecalls_root, output|
      #wrapper.params={"base-calls-directory" => "#{run_basecalls_root}/Data/Intensities/BaseCalls", "output-directory" => output}
      task.options.base_calls_directory=run_basecalls_root
      #puts "Test parametri #{task.inspect}"
      wrapper.run
    end #setup_bcl_conversion

    desc "start_conversion RUN_DIR [JOBS] ", "Start the conversion", :hide => true
    method_option :prova, :type => :string
    def start_conversion(run_basecalls_root, jobs=1)
      # puts jobs
      # puts basecalls
      puts "make recursive -j #{jobs} -f #{run_basecalls_root}/Data/Intensities/BaseCalls/Makefile -C #{run_basecalls_root}/Data/Intensities/BaseCalls"
    end #run_bcl_to_qseq
  end #Qseq
end #Bcl

end #Convert
