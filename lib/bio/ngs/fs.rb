#Bio::Ngs::FS::Project.smart_path :project => "NAME", :files=>true, :exclude => [/SQ_0112/], :from => :tophat, :to=> :cuffdiff

module Bio
  module Ngs
    module FS


      CATEGORIES ={
            :cufflinks=>[/genes\.fpkm_traking/, #same for denovo
                         /isoforms\.fpkm_traking/, #same for denovo
                         /transcripts\.gtf/, #same for denovo
                         /skipped\.gtf/,
                         /genes\.fpkm_tracking/,
                         /isoforms\.fpkm_tracking/], #same for denovo
              
            :cuffdiff=>[/cds\.diff/,
                        /cds_exp\.diff/,
                       /cds\.fpkm_tracking/,
                       /gene_exp\.diff/,
                       /genes\.fpkm_tracking/,
                       /isoform_exp\.diff/,
                       /isoforms\.fpkm_tracking/,
                       /promoters\.diff/,
                       /splicing\.diff/,
                       /tss_group_exp\.diff/,
                       /tss_groups\.fpkm_tracking/],
            :quantification =>[/quantification/],
            :cuffcompare =>[/.*\.tracking/,
                           /.*\.combined\.gtf/,
                           /.*\.loci/,
                           /.*\.stats/],
            :tophat => [/accepted_hits\.bam$/,
                        /deletions\.bed/,
                        /insertions\.bed/,
                        /junctions\.bed/,
                        /left_kept_reads\.info/,
                        /right_kept_reads\.info/,
                        /unmapped_left\.fq\.z/,
                        /unmapped_right\.fq\.z/
                        ],
            :rtfc => [/_L\d{3,3}_R1_\d{3,3}\.trimmed\.fastq\.gz/], #reads_trimmed_forward_chunks
            :rtrc => [/_L\d{3,3}_R2_\d{3,3}\.trimmed\.fastq\.gz/], #reads_trimmed_reverse_chunks
            :rtf => [/_R1\.trimmed\.fastq\.gz/], #reads_trimmed_forward
            :rtr => [/_R2\.trimmed\.fastq\.gz/], #reads_trimmed_reverse
            :rtufc => [/_L\d{3,3}_R1_\d{3,3}\.unpaired\.fastq\.gz/], #reads_trimemd_unpaired_forward_chunks
            :rturc => [/_L\d{3,3}_R2_\d{3,3}\.unpaired\.fastq\.gz/], #reads_trimmed_unpaired_reverse_chunks
            :rtuf => [/_R1\.unpaired\.fastq\.gz/], #reads_trimmed_unpaired_forward
            :rtur => [/_R2\.unpaired\.fastq\.gz/], #reads_trimmed_unpaired_reverse
            :rfc => [/_L\d{3,3}_R1_\d{3,3}\.fastq\.gz/], #reads_forward_chunks
            # elsif file=~/trimmed/ && file=~/_L\d+_R._\d+\./
            #   :trimmed_splitted
            # elsif file=~/trimmed/ 
            #   :trimmed
            :rrc => [/_L\d{3,3}_R2_\d{3,3}\.fastq\.gz/], #reads_reverse_chunks                
            :rf => [/_R1\.fastq\.gz/], #reads_forward  
            :rr => [/_R2\.fastq\.gz/], #reads_reverse                
            :logs => [/logs/],
            :denovo => [/denovo/],
            :rawdata => [/raw_data/,/rawdata/],
            :mapquant => [/MAPQUANT/],
            :mapquant_projects => [/MAPQUANT_Projects/]
}

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
               :tophat_to_cufflinks=>'accepted_hits.bam$',
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

          # Return
          # 0) nil in case of any file
          # 1) an array of files belonging to :from but not :to OR belonging to :to but not :from
          # 2) an array of elements if :from and :to are specifid and exists as RULES
          # 3) a Thor::CoreExt::HashWithIndifferentAccess instance in case :from and :to are not specified together.
          #    to 
          def smart_path(opts={})
            #by default temp|Temp directories are skipped from final result.
            path=["**/*"]
            path << File.join([raw_run(opts[:run]), project(opts[:project]), sample(opts[:sample])].select{|dir| dir})
            if opts[:quant]
              path << "**/*" unless opts[:sample]
              path<<"quantification"
            end
            if opts[:quantdenovo]
              path<<"quantification_denovo"
            end

            if opts[:files]
              path<<"**/*"
            end
            #puts File.join(path)
            data = aggregate_by_topic2(skip_temp(Dir.glob(File.join("**/*",path))), opts)
            if opts[:from] && data.key?(opts[:from]) && opts[:to].nil?
              data[opts[:from]]
            elsif opts[:to] && data.key?(opts[:to]) && opts[:from].nil?
              data[opts[:to]]
            elsif opts[:from] && opts[:to] && rule=RULES["#{opts[:from]}_to_#{opts[:to]}".to_sym]
               # data["#{opts[:from]}_to_#{opts[:to]}".to_sym] = data[opts[:from]].select do |file|
              data[opts[:from]].select do |file|
                file.match(rule)
              end
            else
            #define keys as method for the hash.
            # Maybe better to use Thor::CoreExt::HashWithIndifferentAccess
            # data.keys.each do |key|
            #   data.class_eval do 
            #     self.send :define_method, key do 
            #        self[key]
            #     end #define_method
            #   end #instance_eval
            # end #keys

              Thor::CoreExt::HashWithIndifferentAccess.new data
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

          def aggregate_by_topic2(paths=[], opts={})
            topics = Hash.new {|hash, key| hash[key]=[]}

            paths.each do |path|
              unless (opts[:exclude] && path_has_regexps?(path, opts[:exclude]))
                file_type(path).each do |tag|
                  topics[tag] << path
                end
              end #unless
            end
            topics
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
            CATEGORIES.each do |tag|
              path_has_regexps?(file,tag[1])
            end.map do |tag|
              tag[0]
            end
            # else 
            #   :unk #unkown
            # end
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




