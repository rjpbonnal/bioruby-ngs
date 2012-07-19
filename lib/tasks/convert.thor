#
#  convert.thor - Main task for converting data between NGS formats
#
# Copyright:: Copyright (C) 2011
#     Raoul J.P. Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#




module Convert

  class Bam < Thor 

    # Sort and index the input bam filename
    # the sorted/indexed output is created in the same directory of the input file
    desc "sort BAM [PREFIX]", "Sort and create and index for the BAM file name"
    def sort(bam_fn, prefix=nil)
      if File.exists?(bam_fn)
        dirname = File.dirname(bam_fn)
        prefix = File.basename(bam_fn).gsub(/\.bam/,'_sort') if prefix.nil?
        bam_sort_fn = File.join(dirname, prefix)
        #bam sort
        Bio::DB::SAM::Tools.bam_sort(bam_fn, bam_sort_fn)
        bam_sort_fn += ".bam"
        #bam index sorted file
        Bio::DB::SAM::Tools.bam_index_build(bam_sort_fn)
      else
        warn "[#{Time.now}] There was an error, tophat did not create any accepted_hit file "
      end
      #you tasks here
    end #sort

    desc "merge" ,"Merge multiple bams in a single one, BAMS separated by commmas"
    method_option :input_bams, :type => :array, :required => true, :aliases => '-i'
    method_option :output, :type => :string, :require => true, :aliases => '-o'
    Bio::Ngs::Samtools::Merge.new.thor_task(self, :merge) do |wrapper, task|
      wrapper.params = task.options
      wrapper.run :arguments => [task.options.output, task.options.input_bams].flatten
    end

    desc "extract_genes BAM GENES", "Extract GENES from bam. It connects to Ensembl Humnan, release 61 and download the coordinates for the inserted genes"
    method_option :output, :type => :string, :desc => "output file name"
    method_option :ensembl_specie, :type => :string, :desc => "default homo_sapiens", :default => 'homo_sapiens'
    method_option :ensembl_release, :type => :numeric, :desc => "ensembl release", :required => true 
    Bio::Ngs::Samtools::View.new.thor_task(self, :extract_genes) do |wrapper, task, bam_fn, gene_names|
      require 'ensembl'
      #     begin
      ::Ensembl::Core::DBConnection.connect(task.options.ensembl_specie, task.options.ensembl_release)
      genes_str=gene_names.split(',').map do |gene|
        g = ::Ensembl::Core::Gene.find_by_name(gene)
        if g
          coords = "#{g.seq_region.name}:#{g.seq_region_start}-#{g.seq_region_end}"
        else
          warn "Can't find gene #{gene} in Ensembl #{task.options.ensembl_specie}, release #{task.options.ensembl_release} "
        end
      end.compact
      if File.exists?(bam_fn) && !genes_str.empty?          
        output_name = task.options.output || bam_fn.gsub(/\.bam/, "_subset.bam")
        wrapper.run :arguments => [output_name, bam_fn, genes_str]
        task.invoke :sort, [output_name]
        puts "Find your data in #{output_name} and #{output_name.gsub(/\.bam/,"_sort.bam")}"
      end        
      # rescue Exception => e
      #   warn "Bam file #{bam_fn} does not exsist or you don't have the rights to open it.#{e}"
      # end
    end
  end # Bam

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
              def convert (run_basecalls_root, output, jobs=1)
                invoke :configure_conversion, [run_basecalls_root, output]
                invoke :run_bcl_to_qseq, [run_basecalls_root, jobs]
              end #bcl_to_qseq

              desc "configure_conversion RUN_DIR OUTPUT ", "Configure the specific Run to be converted", :hide => true
              Bio::Ngs::CASAVA::Bclqseq.new.thor_task(self, :configure_conversion) do |wrapper, task, run_basecalls_root, output|
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

            class Fastq < Thor



              desc "convert RUNDIR DATAOUTDIR [SAMPLESHEET]", "Convert a bcl dataset in fastq. By default it creates a directory with the same name of the rawdata dir attaching a postfix _DATA"
              method_option :cpu, :type => :numeric, :desc => "number of cpu to use for demultiplexing", :default => 1
              method_option "sample-sheet", :type=> :string, :default => 'SampleSheet.csv'
              def convert(run_basecalls_root, dataoutdir, samplesheet=nil)
                configure_conversion(run_basecalls_root, dataoutdir)
                start_conversion(dataoutdir, options[:cpu])
              end #convert bcl to fastq

              desc "configure_conversion RUNDIR DATAOUTDIR", "Configure the specific Run to be converted"
              Bio::Ngs::CASAVA::ConfigBclFastq.new.thor_task(self, :configure_conversion) do |wrapper, task, run_basecalls_root, dataoutdir|
                base_calls_dir = File.join(run_basecalls_root, "Data/Intensities/BaseCalls")

                if sample_sheet=task.options["sample-sheet"]
                  if File.dirname(sample_sheet) == '.'
                    if File.exists?(File.join(base_calls_dir,sample_sheet))
                      #default place
                      sample_sheet = File.join(base_calls_dir,sample_sheet)
                    elsif File.exists?(File.join(run_basecalls_root,sample_sheet))
                      #search for sample sheet in the root of raw data directoy
                      sample_sheet = File.join(run_basecalls_root,sample_sheet)
                    else
                      raise "Unable to find a valid sample sheet: #{sample_sheet}"
                    end
                  elsif !File.exists?(sample_sheet)
                    raise "Unable to find a valid sample sheet: #{sample_sheet}"
                  end
                end
                wrapper.params={"input-dir" => "#{run_basecalls_root}/Data/Intensities/BaseCalls", "output-dir" => dataoutdir, "sample-sheet" => sample_sheet}
                wrapper.run
              end


              desc "start_conversion CONF_DATA_DIR", "Start the conversion"
              def start_conversion(conf_data_dir, cpu)
                Dir.chdir(conf_data_dir) do 
                  `make -j "#{cpu}"`
                end
              end #start_conversion

            end #Fastq
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

            class Humanize < Thor
              require 'json'

              desc "build_compare_kb GTF", "Build the JSON file with the annoation from the GTF file used to humanize the results"
              #TODO: create a zip file to optimize the space.
              def build_compare_kb(gtf)
                Bio::Ngs::Cufflinks::Compare.build_compare_kb(gtf)
                # unless File.exists?(gtf)
                #   STDERR.puts "File #{gtf} doesn't exist."
                #   return nil
                # end
                # dict = {} #build an hash with the combinations of data extracted from GTF file, XLOC, TCONS, ENST, SYMBOL
                # File.open(gtf,'r') do |f|
                #   f.lines do |line|
                #     line=~/gene_id (.*?);/
                #     gene_id = $1.gsub(/"/,'').to_sym
                #     line=~/transcript_id (.*?);/
                #     transcript_id = $1.gsub(/"/,'').to_sym
                #     line=~/gene_name (.*?);/
                #     gene_name = $1.gsub(/"/,'').to_sym
                #     line=~/oId (.*?);/
                #     oid=$1.gsub(/"/,'').to_sym
                #     line=~/nearest_ref (.*?);/
                #     nearest_ref = $1.gsub(/"/,'').to_sym
                #     dict[gene_id]={:transcript_id=>transcript_id, :gene_name=>gene_name, :odi=>oid, :nearest_ref=>nearest_ref}
                #     dict[transcript_id]={:gene_id=>gene_id, :gene_name=>gene_name, :odi=>oid, :nearest_ref=>nearest_ref}
                #     dict[gene_name]={:gene_id=>gene_id, :transcript_id=>transcript_id, :odi=>oid, :nearest_ref=>nearest_ref}
                #     dict[oid]={:gene_id=>gene_id, :transcript_id=>transcript_id, :gene_name=>gene_name, :nearest_ref=>nearest_ref}
                #     dict[nearest_ref]={:gene_id=>gene_id, :transcript_id=>transcript_id, :odi=>oid, :gene_name=>gene_name}
                #   end#lines
                # end#file
                # kb_filename = gtf.sub(/\.[a-zA-Z0-9]*$/,".kb")
                # File.open(kb_filename,'w') do |fkb|
                #   #fkb.write(dict.to_json)
                #   Marshal.dump(dict,fkb)
                # end #fkb
              end

              desc "isoform_exp GTF ISOFORM", "tag the XLOC gathering information from GTF (ensembl)"
              #TODO: open a zip file,KB to optimez performances
              def isoform_exp(gtf, isoform)
                unless File.exists?(gtf)
                  STDERR.puts "File #{gtf} doesn't exist."
                  return nil
                end

                unless File.exists?(isoform)
                  STDERR.puts "File #{isoform} doesn't exist."
                  return nil
                end

                unless File.exists?(kb_filename = gtf.sub(/\.[a-zA-Z0-9]*$/,".kb"))
                  #build the kb                    
                  invoke :build_compare_kb, [gtf]
                end

                gtf_gkb = Bio::Ngs::Cufflinks::Compare.load_compare_kb(kb_filename)
                # gtf_kb = File.open(kb_filename,'r') do |kb_dump|
                #   Marshal.load(kb_dump)
                # end

                File.open("#{isoform}_rich", 'w') do |w|
                  File.open(isoform,'r') do |f|
                    w.write("ensembl_transcript_id\t#{f.readline}") #skip header and write to output files
                    f.each_line do |line|
                      data = line.split                        
                      w.write("#{gtf_kb[data[0].to_sym][:nearest_ref]}\t#{line}")
                    end #line
                  end #file read
                end #file write
              end#isoform_exp

            end #Humanize

            class De < Thor

              #./bin/biongs convert:illumina:de:isoform /Users/bonnalraoul/Desktop/RRep16giugno/DE_lane1-2-3-4-6-8/DE_lane1-2-3-4-6-8/isoform_exp.diff /Users/bonnalraoul/Desktop/RRep16giugno/COMPARE_lane1-2-3-4-6-8/COMPARE_lane1-2-3-4-6-8.combined.gtf --min_samples=5 --fold=2 --min_fpkm=0.5 --z_score | sort > /Users/bonnalraoul/Desktop/RRep16giugno/DE_lane1-2-3-4-6-8/DE_lane1-2-3-4-6-8/isoform_exp_diff.txt


              #Extract data from differential expression made by Cuffdiff.
              #The user can request to export the data in a tabular format with data in fpkm or z-score (computed by row)
              #Is possible to filter the results in different manners:
              #by fold change: log2 (internally Cuffdiff compute a fold change with natural logarithm, this task made an internal conversion)
              #by number of elmentes for with the fold change is verified among the remaining populations/samples
              #by fpkm a poulation/samples is take into account by further selection steps if it's fpkm value is greater_equal to...       
              #the output is writted to a tab delimited table, sorted by the first column:sample-discriminator.
              #Output file name isoform_exp-f1_s5_fpkm0.5_z.txt, the parameters are written in the file name, so is possible to keep track of them
              desc "isoform DIFF GTF", "extract the transcripts"
              method_option :fold, :type => :numeric, :desc => "DE fold change log2", :default=>0.0
              method_option :only_significative, :type => :boolean, :aliases=>'-s', :default=>false
              method_option :min_samples, :type=>:numeric, :aliases=>"-m", :desc=>"Niminim number of item for the the fold must be verified or significative"
              method_option :min_fpkm, :type => :numeric, :aliases => "-f", :default=> 0.0, :desc => "Store a value if its fpkm is at least"
              method_option :z_scores, :type => :boolean, :aliases => "-z", :default=> false, :desc=> "Return a matrix of Z-scores other than fpkm"
              method_option :up, :type => :boolean, :aliases => '-u', :default => true, :desc => "Up regulated (true), down regulated (false)"
              def isoform(diff_file, gtf)
                how_regulated = options.up ? :up : :down
                Bio::Ngs::Cufflinks::Diff.isoforms(diff_file,
                gtf,
                fold:options.fold,min_samples:options.min_samples,min_fpkm:options.min_fpkm,z_scores:options.z_scores, regulated:how_regulated)
              end #de_isoform

              desc "gene DIFF GTF", "extract the transcripts"
              method_option :fold, :type => :numeric, :desc => "DE fold change log2", :default=>0.0
              method_option :only_significative, :type => :boolean, :aliases=>'-s', :default=>false
              method_option :min_samples, :type=>:numeric, :aliases=>"-m", :desc=>"Niminim number of item for the the fold must be verified or significative"
              method_option :min_fpkm, :type => :numeric, :aliases => "-f", :default=> 0.0, :desc => "Store a value if its fpkm is at least"
              method_option :z_scores, :type => :boolean, :aliases => "-z", :default=> false, :desc=> "Return a matrix of Z-scores other than fpkm"
              method_option :up, :type => :boolean, :aliases => '-u', :default => true, :desc => "Up regulated (true), down regulated (false)"
              method_option :force_not_significative, :type=>:boolean, :aliases=>'n', :default=>false, :desc=>"consider not significan value dutin computation of signature."
              def gene(diff_file, gtf)
                how_regulated = options.up ? :up : :down
                Bio::Ngs::Cufflinks::Diff.genes(diff_file,
                gtf,
                fold:options.fold,min_samples:options.min_samples,min_fpkm:options.min_fpkm,z_scores:options.z_scores, regulated:how_regulated)
              end #de_isoform

              #convert:illumina:de:rename_qs /Users/bonnalraoul/Desktop/RRep16giugno/DEpopNormNOTh2s1NOTh17s1_lane1-2-3-4-6-8/gene_exp-f0.5_s5_fpkm0.5_zup.txt\
              # Naive,Th1,Th17,Th2,Treg,Tfh
              desc "rename_qs DIFF_FILE NAMES", 'rename q1,...,qn with names provided by the user(comma separated)'
              def rename_qs(diff_file, names)
                names_list = names.split(',')
                File.open(diff_file+"_renamed",'w') do |w|
                  File.open(diff_file, 'r') do |f|
                    header = f.readline
                    names_list.each_with_index{|name,idx| header.gsub!(/q#{idx+1}/,name)}
                    w.puts header
                    f.each_line do |line|
                      line.scan(/q\d+/).each do |q|
                        line.gsub!(/#{q}/,names_list[q.tr('q','').to_i-1])
                      end #scan
                      w.puts line
                    end #each_line
                  end# open-read
                end #open-write
              end
            end #De

          end #Illumina


          # desc "list2table LIST", "reorganize a list of pairs key value in a table of key values. Tabular is the default separator"
          # def list2table(list)
          #   dict = Hash.new{|h,k| h[k]=[]}
          #     File.open(ARGV[0],'r') do |f|
          #     f.each_line do |l|
          #        key, value = l.split
          #        dict[key]<<value
          #     end
          #   end

          #   dict.each_pair do |key, values|
          #     puts "#{key} #{values.join('  ')}"
          #   end
          # end
  class Cuff < Thor
    desc "fix_compare GTF", "transform Cuffcompare output from only exons to transcripts/exons relationship. Send result in stdout"
    def fix_compare(gtf)
      Bio::Ngs::Cufflinks::Compare.fix_gtf(gtf)
    end

    desc "to_ttl GTF", "convert a Cufflinks GTF quantification file in RDF Turtle format. Data are sent in stdout."
    def to_ttl(gtf)
      if File.exists?(gtf)
        data = Bio::Ngs::Cufflinks::Gtf.new(gtf)
        data.to_ttl
      else
        raise 
      end
    end
  end
end #Convert
        #  Add methods to Enumerable, which makes them available to Array
