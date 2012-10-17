#Bio::Ngs::FS::Project.smart_path :project => "NAME", :files=>true, :exclude => [/SQ_0112/], :from => :tophat, :to=> :cuffdiff

module Bio
  module Ngs
    module FS
      # def self.included(base)
      #   base.extend(ClassMethods)
      # end
      class << self
        # Write a file 'merged' which is the concatenation of multipes fastq.gz 'files'
        # files is an array of filenames
        def cat(files, merged)
            if files.is_a? Array
              File.open(merged,'wb') do |fmerge|
                files.each do |fname|
                  File.open(fname,'rb:binary') do |file|
                    while line = file.gets
                      fmerge << line
                    end
                  end #read
                end #each
              end #write
            end #if
        end #cat
        alias :merge :cat


        def files(everything, suffix=nil)
          if everything.is_a? String
            if File.file? everything
              [File.expand_path(everything)]
            elsif File.directory? everything
                files(Dir.glob(File.join(everything, suffix.nil? ? "*" : "*"+suffix)).select{|item| File.file? item}).flatten
            elsif everything=~/\*/
              files(Dir.glob(everything)).flatten
            elsif everything=~/[ ,:;]/
             files(everything.split(/[ ,:;]/))
            end
          elsif everything.is_a? Array
            everything.map do |item|
              files(item)
            end.flatten
          end
        end #files

      end  #self
      module Project
        RULES={:tophat_to_cuffdiff=>'accepted_hits.bam$',
               :cufflinks_to_cuffmerge=>'transcripts.gtf'
        }

        class << self
          def raw_run(name)
            unless name.nil?
              name=File.join("raw_data", name) unless name=~/raw_data/
              unless File.exists?(name)
                name="#{name}*"
              end
              name
            end
          end #raw_run

          def project(name)
            unless name.nil?
              if name.to_sym == :all
                name="Project_*"
              elsif name !~ /Project_/
                name="Project_#{name}"
              end
              name
            end
          end #project

          def projects
            prjs= Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = [] }  }
            data = smart_path :project=> :all
            data.each_pair do |key, paths|
              paths.each do |path|
                info=strip_name(path)
                prjs[info[0]][key] << info[1]
              end
            end
            prjs
          end

          def sample(name)
            unless name.nil?
              name="Sample_#{name}*" unless name=~/Sample_/
              name
            end
          end #sample

          def smart_path(opts={})
            root = opts[:root] || './'
            path = [root,"**/*"]
            #by default temp|Temp directories are skipped from final result.
            ary_path = [raw_run(opts[:run]), project(opts[:project]), sample(opts[:sample])].select{|dir| dir}
            path << File.join(ary_path) unless ary_path.empty?
            if opts[:quant]
              path << "**/*" unless opts[:sample]
              path<<"quantification"
            elsif opts[:quantdenovo]
              path<<"quantification_denovo"
            end

            if opts[:files]
              path<<"**/*"
            end
            data = aggregate_by_topic(skip_temp(Dir.glob(File.join(path))), opts)
            if opts[:from] && data.key?(opts[:from]) && opts[:to].nil?
              data[opts[:from]]
            elsif opts[:from] && opts[:to] && rule=RULES["#{opts[:from]}_to_#{opts[:to]}".to_sym]
              data[opts[:from]].select do |file|
                file.match(rule)
              end
            else
              data
            end
          end #smart_path

          # return an hash key value for Sample or Project
          # like [ :Duck , "complete path to duck"] 
          def strip_name(path)
            
            #path=~/(Sample|Project)_(.*?)\/{0,1}/
            #type=$1
            name=path.gsub(/.*(Sample|Project)_/,'').gsub(/[\/\.].*$/,'')
            [name, path]
          end


          def list(opts={})
             opts[:runs]
             opts[:projects]
             opts[:samples]
           end #list          

          # regexps is an array or a single string of regular expression(s)
          def path_has_regexps?(path, regexps)
            # puts path
            # puts regexps
            if regexps.is_a? Regexp
              path=~regexps
            elsif regexps.is_a? String
              path.match(regexps)
            elsif regexps.is_a? Array
              regexps.find do |regexp|
                path_has_regexps?(path, regexp)
              end
            end
          end

          def aggregate_by_topic(paths=[], opts={})
            #:exclude = remove something passing a regular expression
            topics = Hash.new {|hash, key| hash[key]=[]}

            paths.each do |path|
              unless (opts[:exclude] && path_has_regexps?(path, opts[:exclude]))
              if Dir.exists?(path)
                if path=~/raw_data/
                  topics[:raw_data] << path
                elsif path=~/MAPQUANT\//
                  topics[:map_quant] << path
                elsif path=~/MAPQUANT_Projects\//
                  topics[:map_quant_projects] << path
                # elsif path=~/quantification\//
                #   topics[:quant] << path
                # elsif path=~/quantification_denovo\//
                #   topics[:quantdenovo] << path
                elsif path=~/logs\//
                  topics[:logs] << path
                end
              elsif File.exists?(path)
                  topics[file_type(path)] << path
              end
              end #unless
            end
            topics
          end #aggregate_by_topic

          #file type form filename
          def file_type(file)
            if file=~/accepted_hits\.bam/
              :tophat
            elsif file=~/genes\.fpkm_traking/
              :cufflinks #same for denovo
            elsif file=~/isoforms\.fpkm_traking/
              :cufflinks #same for denovo
            elsif file=~/transcripts\.gtf/
              :cufflinks #same for denovo
            elsif file=~/skipped\.gtf/
              :cufflinks #same for denovo
            elsif file=~/cds\.diff/
              :cuffdiff
            elsif file=~/cds_exp\.diff/
              :cuffdiff
            elsif file=~/cds\.fpkm_tracking/
              :cuffdiff
            elsif file=~/gene_exp\.diff/
              :cuffdiff
            elsif file=~/genes\.fpkm_tracking/ && file=~/quantification/
              :cufflinks
            elsif file=~/genes\.fpkm_tracking/
              :cuffdiff
            elsif file=~/isoform_exp\.diff/
              :cuffdiff
            elsif file=~/isoforms\.fpkm_tracking/ && file=~/quantification/
              :cufflinks              
            elsif file=~/isoforms\.fpkm_tracking/
              :cuffdiff
            elsif file=~/promoters\.diff/
              :cuffdiff
            elsif file=~/splicing\.diff/
              :cuffdiff
            elsif file=~/tss_group_exp\.diff/
              :cuffdiff                
            elsif file=~/tss_groups\.fpkm_tracking/
              :cuffdiff
            elsif file=~/.*\.tracking/
              :cuffcompare
            elsif file=~/.*\.combined\.gtf/
              :cuffcompare
            elsif file=~/.*\.loci/
              :cuffcompare
            elsif file=~/.*\.stats/
              :cuffcompare
            elsif file=~/deletions\.bed/
              :tophat
            elsif file=~/insertions\.bed/
              :tophat
            elsif file=~/junctions\.bed/
              :tophat
            elsif file=~/left_kept_reads\.info/
              :tophat
            elsif file=~/right_kept_reads\.info/
              :tophat
            elsif file=~/unmapped_left\.fq\.z/
              :tophat
            elsif file=~/unmapped_right\.fq\.z/
              :tophat
            # elsif file=~/trimmed/ && file=~/_L\d+_R._\d+\./
            #   :trimmed_splitted
            # elsif file=~/trimmed/ 
            #   :trimmed
            elsif file=~/_L\d{3,3}_R1_\d{3,3}\.trimmed\.fastq\.gz/
              :rtfc #reads_trimmed_forward_chunks
            elsif file=~/_L\d{3,3}_R2_\d{3,3}\.trimmed\.fastq\.gz/                
              :rtrc #reads_trimmed_reverse_chunks
            elsif file=~/_R1\.trimmed\.fastq\.gz/
              :rtf #reads_trimmed_forward
            elsif file=~/_R2\.trimmed\.fastq\.gz/                
              :rtr #reads_trimmed_reverse

            elsif file=~/_L\d{3,3}_R1_\d{3,3}\.unpaired\.fastq\.gz/
              :rtufc #reads_trimemd_unpaired_forward_chunks
            elsif file=~/_L\d{3,3}_R2_\d{3,3}\.unpaired\.fastq\.gz/                
              :rturc #reads_trimmed_unpaired_reverse_chunks
            elsif file=~/_R1\.unpaired\.fastq\.gz/
              :rtuf #reads_trimmed_unpaired_forward
            elsif file=~/_R2\.unpaired\.fastq\.gz/                
              :rtur #reads_trimmed_unpaired_reverse

            elsif file=~/_L\d{3,3}_R1_\d{3,3}\.fastq\.gz/
              :rfc #reads_forward_chunks
            elsif file=~/_L\d{3,3}_R2_\d{3,3}\.fastq\.gz/                
              :rrc #reads_reverse_chunks
            elsif file=~/_R1\.fastq\.gz/
              :rf #reads_forward
            elsif file=~/_R2\.fastq\.gz/                
              :rr #reads_reverse
            elsif file=~/logs/
              :logs
              # Sample_SQ_0051_R2.fastq.gz
            else 
              :unk #unkown
            end
          end

          def skip_temp(files=[])
            files.select do |file_path|
              !(file_path=~/[T|t]emp/)
            end
          end #skip_temp
        end #self
      end #Project


        # module MIME
          module Type
          
          def self.included(base)
            base.extend(ClassMethods)
          end            
          
          module ClassMethods

            attr_accessor :files

            @@files={}

        # def inherited(subclass)
        #   self.instance_variables.each do |var|
        #     subclass.instance_variable_set(var, self.instance_variable_get(var))
        #   end
        # end

            def output_file(filename, opts={})
              # opts are keywords like:
              # as:TheNameToGetThisFileAsAMethod
              # regexp:InCaseOfManyFilesARegularExpressionCanBeEvaluatedToIdentifyTheFilename
              puts filename
              puts @@files.class
             #  unless files[opts[:as] || :output]
             #    files[opts[:as] || :output]=[]
             #  end

             #  method_name = (opts[:as] ? opts[:as] : filename.gub(/\..*$/,'')).to_sym
             #  puts filename
             #  puts files.class
             #  #@files[method_name] << filename
             #    self.class.send  :define_method, method_name do |path = '.', &block|
             #      files[method_name].each do |file|
             #        block.call(file)
             #      end #each files
             #    end #define_method
             # #else
             # #   raise "#{type_file_name} is not a valid base name for cuffdiff's output, must be plural and in this set: genes, cds, isoforms, tss_groups"
             # #end #if
            end #output_file
          end #ClassMethod
        end #Type
    # end #MIME


    end #FS
  end #Ngs
end #Bio




