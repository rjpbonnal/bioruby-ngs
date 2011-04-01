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
          qseq.buffer = File.open(file_name,'r') #todo: dir is not used here it could be a bug
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

      # This tasks is used to aggregate the data demultiplexed from Illumina OLB 1.9 and CASAVA 1.7.
      # Demultiplexing software splits the reads in different subdirectories based on the tag index of the reads,
      # usually the wet-lab puts a population in a single lane an tags it with different indexes. The demultiplexer
      # behaviour is not so clear, so this task takes care of simplify the aggregation for the final dataset.
      # Output: 2 files
      # 1) Forward fastq
      # 2) Reverse fastq
      desc "by_lane LANE OUTPUT", "Convert all the file in the current and descendant directories belonging to the specified lane in fastq. This command is specific for Illumina qseqs file s_#LANE_#STRAND_#TILE. Note UNKOWN directory is excluded by default."
      method_option :paired, :type => :boolean, :default => false, :desc => 'Convert the reads in the paired format searching in the directories.'
      method_option :append, :type => :boolean, :default => false, :desc => 'Append this convertion to the output file if exists'      
      method_option :dir, :type => :string, :desc => 'Path to the working directory (data)'
      # output is just a string I'll attach the fastq extension
      def by_lane(lane, output)
        dir = options.dir || Dir.pwd

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

          desc "by_lane_index LANE INDEX OUTPUT", "Convert the qseq from a line and index in a fastq file"
          method_option :paired, :type => :boolean, :default => false, :desc => 'Convert the reads in the paired format searching in the directories.'
          method_option :append, :type => :boolean, :default => false, :desc => 'Append this convertion to the output file if exists'      
          method_option :dir, :type => :string, :desc => 'Path to the working directory (data)'
          # output is just a string I'll attach the fastq extension
          def by_lane_index(lane, index, output)
            dir = options.dir || Dir.pwd 
            paired = options.paired
            append = options.append
            index_str = "%03d" % index
            strand_lambda = lambda do |dir, strand| #Forward
              strand_number = case strand 
              when :forward then 1
              when :reverse then 2
              end              
              invoke :by_file, [Dir[File.join(dir,"#{index_str}/s_#{lane}_#{strand_number}_*_qseq.txt")], "#{output}_#{strand}"], :paired => paired, :append => append, :dir => dir
            end

            forward_daemon_options = {
              :app_name   => "forward_#{lane}_#{index_str}",
              :ARGV       => ['start'],
              :log_output => true,
              :dir_mode => :normal,
              :dir => dir}
              forward_task = ::Daemons.run_proc("forward_#{lane}_#{index_str}",forward_daemon_options ) do
                strand_lambda.call(dir,:forward)         
              end #daemon1

              #Reverse
              if options.paired
                reverse_daemon_options = {
                  :app_name   => "reverse_#{lane}_#{index_str}",
                  :ARGV       => ['start'],
                  :log_output => true,
                  :dir_mode => :normal,
                  :dir => dir}            
                  reverse_task = ::Daemons.run_proc("reverse_#{lane}_#{index_str}",reverse_daemon_options) do
                    strand_lambda.call(dir, :reverse)
                  end #daemon2
                end #ifpaired
              end #by_lane_index

              # SAMPLES = 1,2,3,4
              # LANE = 1
              #OUTOUP = File name prefix, output file name will be OOUTPUT-Sample_N....
              desc "samples_by_lane SAMPLES LANE OUTPUT", "Convert the qseqs for each sample in a specific lane. SAMPLES is an array of index codes separated by commas lane is an integer"
              method_option :paired, :type => :boolean, :default => false, :desc => 'Convert the reads in the paired format searching in the directories.'
              method_option :append, :type => :boolean, :default => false, :desc => 'Append this convertion to the output file if exists'
              def samples_by_lane(samples, lane, output)
                dir = Dir.pwd
                  samples.split(",").each do |sample|
                    sample_idx = sample.to_i
                    ::Daemons.run_proc("sample#{sample}_by_lane-#{lane}", {:app_name   => "sample#{sample}_by_lane-#{lane}",
                      :ARGV       => ['start'],
                      :log_output => true}) do
                       invoke :by_lane_index, [lane, sample_idx, "#{output}-Sample_#{sample_idx}"], :paired => options.paired, :append =>options.append, :dir => dir
                    end
                  end
                end #samples_by_lane

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

                # Trim fastq sequences (Illumina format 1.5+):
                # ------------------BBBBBBBBBBBBBBBBB
                # ------------------
                # First step trailing Bs are removed and if the remaining sequence is length enough
                # The user can specify the minimum length of the sequnce and the number of Bs to search in the middle.
                # If user passes an output file name that witll be used as suffix for the other output files.
                # If no file name is passed the input file name will be used as suffix.
                # Output: 4 files
                # 1) xxx_trim.fastq the trimmed sequences in fastq format
                # 2) xxx_rejected.fastq
                # 3) xxx_profile.csv the length distribution of the trimmed sequnces
                # 4) xxx_report.csv statistics on processed reads as total number of reads in input,
                #    trimmed, removed, untouched ( not trimmed)
                # Note: removed reads are the ones which start with a B
                # IMPORTANT: Data in FastQ formant MUST NOT BE WRAPPED sequence and quality MUST BE ON 1 LINE EACH
                desc "trim_b FASTQ", "perform a trim on all the sequences on B qualities with Illumina's criteria. Ref to CASAVA manual."
                #TODO, report the legth/profile of all the sequences.
                #TODO: implement different strategies for trimming, N consecutive Bs ?
                #TODO: implement min length for a trimmed sequnce to be reported as valid.
                method_option :fileout, :type => :string
                method_option :min_size, :type =>:numeric, :default => 20, :aliases => '-s', :desc => 'minimum length to consider a trimmed sequence as valid, otherwise it will be discarded'
                def trim_b(fastq)
                  reads = File.open(fastq,'r')            
                  output_filename_base = options[:fileout].nil? ? fastq : options.fileout
                  count_total = 0
                  count_trimmed = 0
                  count_removed = 0
                  sequences_profile=Hash.new(0)
                  fastq=0
                  head =""
                  seq=""
                  qual=""
                  min_size = (options[:min_size] > 1) ? (options[:min_size]-1) : 0

                  trimming_tail_patter = /B*$/

                  r_rejected = File.open(Bio::Ngs::Utils.tag_filename(output_filename_base, "trim_rejected","fastq"), 'w')

                  File.open(Bio::Ngs::Utils.tag_filename(output_filename_base, "trim", "fastq"), 'w') do |f|
                    reads.lines do |line|
                      case (fastq % 4 )
                      when 0 then
                        head = line
                        count_total+=1
                      when 1 then seq=line
                        #2 is the plus sign
                      when 3 then 
                        b_tail_idx=(line=~trimming_tail_patter)
                        if (b_tail_idx > min_size )
                          count_trimmed+=1
                          f.puts "#{head}#{seq[0..b_tail_idx-1]}\n+\n#{$`}" #remaining_line}"#line[0..b_tail_idx]
                        else
                          count_removed+=1
                          r_rejected.puts "#{head}#{seq}+\n#{line}"                    
                        end
                      end #case
                      fastq+=1                
                    end#read
                  end #Write fastq
                  r_rejected.close
                  #Profile
                  File.open(Bio::Ngs::Utils.tag_filename(output_filename_base, "trim_profile", "csv"), 'w') do |f_profile|
                    f_profile.puts "Sequnce length,count"
                    sequences_profile.sort.each do |profile|
                      read_size = profile[0]
                      read_number = profile[1]
                      f_profile.puts "#{read_size},#{read_number}"
                    end
                  end #Write profile
                  #Report
                  File.open(Bio::Ngs::Utils.tag_filename(output_filename_base, "trim_report", "csv"), 'w') do |report|
                    report.puts "Reads processed,Reads trimmed,Reads removed,Reads untouched"
                    report.puts "#{count_total},#{count_trimmed},#{count_removed},#{count_total-count_trimmed-count_removed}"
                  end #Write report
                end #trim_b
              end #Fastq
            end #Illumina

          end #Convert
