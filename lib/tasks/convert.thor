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
      method_option :dir, :type => :string, :default=>".", :desc => 'Path to the working directory (data)'
      # output is just a string I'll attach the fastq extension
      def by_file(first, output)
        qseq = Bio::Ngs::Converter::Qseq.new(options.paired ? :pe : :se)
        qseq.buffer = File.open(first,'r')
        fastq_file = File.open(File.join(options.dir,"#{output}.fastq"), (options.append ? 'a' : 'w'))
        qseq.to_fastq do |fastq|
          fastq_file.puts fastq if fastq
        end
        fastq_file.close
        #Write the report
        File.open(File.join(options.dir,"#{output}.stats"), (options.append ? 'a' : 'w')) do |file|
          file.puts ({:file_name=>first, :stats=>qseq.stats}.to_yaml)
        end
      end #by_file

      desc "by_lane LANE OUTPUT", "Convert all the file in the current and descendant directories belonging to the specified lane in fastq. This command is specific for Illumina qseqs file s_#LANE_#STRAND_#TILE. Note UNKOWN directory is excluded by default."
      method_option :paired, :type => :boolean, :default => false, :desc => 'Convert the reads in the paired format searching in the directories.'
      method_option :append, :type => :boolean, :default => false, :desc => 'Append this convertion to the output file if exists'      
      # output is just a string I'll attach the fastq extension
      def by_lane(lane, output)
          dir = Dir.pwd
          strand_lambda = lambda do |dir, strand| #Forward
            strand_number = case strand 
                            when :forward then 1
                            when :reverse then 2
                            end              
            Dir[File.join(dir,"00?/s_#{lane}_#{strand_number}_*_qseq.txt")].each do |qseq_reads|
              invoke :by_file, [qseq_reads, "#{output}_#{strand}"], :paired => options.paired, :append => options.append, :dir => dir
            end
          end

          forward_daemon_options = {
            :app_name   => "#{lane}_forward",
            :ARGV       => ['start'],
            :log_output => true}
          task1 = ::Daemons.run_proc("forward",forward_daemon_options ) do
            strand_lambda.call(dir,:forward)         
          end #daemon1

          #Reverse
          if options.paired
            reverse_daemon_options = {
              :app_name   => "#{lane}_reverse",
              :ARGV       => ['start'],
              :log_output => true}            
            task2 = ::Daemons.run_proc("reverse",reverse_daemon_options) do
              strand_lambda.call(dir, :reverse)
            end #daemon2
          end #ifpaired
          
          puts task1.show_status.inspect
        end #by_lane
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
