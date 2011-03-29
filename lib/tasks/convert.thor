#
#  convert.thor - Main task for converting data between NGS formats
#
# Copyright:: Copyright (C) 2011
#     Raoul J.P. Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#

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
        buffers = [first] if first.kind_of? String
        buffers = first if first.kind_of? Array
        buffers.each do |file_name|
          qseq.buffer = File.open(file_name,'r')
          fastq_file = File.open(File.join(options.dir,"#{output}.fastq"), (options.append ? 'a' : 'w'))
          qseq.to_fastq do |fastq|
            fastq_file.puts fastq if fastq
          end
          qseq.buffer.close
          fastq_file.close        
          #Write the report
          File.open(File.join(options.dir,"#{output}.stats"), (options.append ? 'a' : 'w')) do |file|
            file.puts ({:file_name=>file_name, :stats=>qseq.stats}.to_yaml)
          end
        end #buffers
        # puts "Done #{file_name}"
      end #by_file

      #THIS WORKS ONLY ON ILLUMINA DATA DEMULTIPLEXED
      desc "by_lane LANE OUTPUT", "Convert all the file in the current and descendant directories belonging to the specified lane in fastq. This command is specific for Illumina qseqs file s_#LANE_#STRAND_#TILE. Note UNKOWN directory is excluded by default."
      method_option :paired, :type => :boolean, :default => false, :desc => 'Convert the reads in the paired format searching in the directories.'
      method_option :append, :type => :boolean, :default => false, :desc => 'Append this convertion to the output file if exists'      
      # output is just a string I'll attach the fastq extension
      def by_lane(lane, output)
        dir = Dir.pwd

        paired = options.paired
        append = options.append
        strand_lambda = lambda do |dir, strand| #Forward
          strand_number = case strand 
          when :forward then 1
          when :reverse then 2
          end              
          invoke :by_file, [Dir[File.join(dir,"00?/s_#{lane}_#{strand_number}_*_qseq.txt")], "#{output}_#{strand}"], :paired => paired, :append => append, :dir => dir
        end

        forward_daemon_options = {
          :app_name   => "forward_#{lane}",
          :ARGV       => ['start'],
          :log_output => true}
          forward_task = ::Daemons.run_proc("forward_#{lane}",forward_daemon_options ) do
            strand_lambda.call(dir,:forward)         
          end #daemon1

          #Reverse
          if options.paired
            reverse_daemon_options = {
              :app_name   => "reverse_#{lane}",
              :ARGV       => ['start'],
              :log_output => true}            
              reverse_task = ::Daemons.run_proc("reverse_#{lane}",reverse_daemon_options) do
                strand_lambda.call(dir, :reverse)
              end #daemon2
            end #ifpaired
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
      module Illumina
        class Fastq < Thor
          
          
          # Trim fastq sequences (Illumina format 1.5+) starting from the first B in the quality sequence.
          # If user passes an output file name that witll be used as suffix for the other output files.
          # If no file name is passed the input file name will be used as suffix.
          # Output: 3 files
          # 1) xxx.fastq_trim the trimmed sequences in fastq format
          # 2) xxx.fastq_profile the length distribution of the trimmed sequnces
          # 3) xxx.fastq_report statistics on processed reads as total number of reads in input,
          #    trimmed, removed, untouched ( not trimmed)
          # Note: removed reads are the ones which start with a B
          desc "trim_b FASTQ", "perform a trim on all the sequences on B qualities with Illumina's criteria. Ref to CASAVA manual."
          #TODO, report the legth/profile of all the sequences.
          method_option :fileout, :type => :string  
          def trim_b(fastq)
            #reads = Bio::Ngs::FastQuality.new(fastq, :fastq_illumina)
            reads = Bio::FlatFile.auto(fastq)
            count_total = 0
            count_trimmed = 0
            count_removed = 0
            sequences_profile=Hash.new(0)
            File.open(options[:fileout].nil? ? "#{fastq}_trim" : options.fileout, 'w') do |f|
              reads.each do |read|
                count_total+=1
                read.format = :fastq_illumina
                if (b_index=read.quality_scores.find_index {|quality| quality == 2})
                  if (b_index > 0)
                    count_trimmed+=1
                    sequences_profile[b_index]+=1
                    f.puts "@#{read.entry_id}\n#{read.seq[0..(b_index-1)].scan(/.{1,70}/).join("\n")}\n+\n#{read.quality_string[0..(b_index-1)].scan(/.{1,70}/).join("\n")}"
                    #                    fastq_string = "@#{read.entry_id}\n#{read.seq[0..(b_index-1)]}\n+\n#{read.quality_string[0..(b_index-1)]}"
                    #                    trim_read = Bio::Fastq.new(fastq_string)
                    #                    trim_read.format = :fastq_illumina
                    #                    f.puts trim_read.to_biosequence.output(:fastq_illumina)
                  else
                    count_removed+=1
                  end
                else
                  sequences_profile[read.seq.length]+=1
                  f.puts "@#{read.entry_id}\n#{read.seq.scan(/.{1,70}/).join("\n")}\n+\n#{read.quality_string.scan(/.{1,70}/).join("\n")}"
                  #                  f.puts read.to_biosequence.output(:fastq_illumina)
                end #find sequence to trim
              end#read
            end #Write fastq
          File.open(options[:fileout].nil? ? "#{fastq}_profile" : options.fileout, 'w') do |f_profile|
            f_profile.puts "Sequnce length,count"
            sequences_profile.each_pair do |length, count|
              f_profile.puts "#{length},#{count}"
            end
          end #Write profile
            File.open(options[:fileout].nil? ? "#{fastq}_report" : options.fileout, 'w') do |report|
              report.puts "Reads processed,Reads trimmed,Reads removed,Reads untouched"
              report.puts "#{count_total},#{count_trimmed},#{count_removed},#{count_total-count_trimmed-count_removed}"
            end #Write report
          end #trim_b
        end #Fastq
      end #Illumina

    end #Convert
