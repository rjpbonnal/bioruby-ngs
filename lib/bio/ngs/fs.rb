#Bio::Ngs::FS::Project.smart_path :project => "NAME", :files=>true, :exclude => [/SQ_0112/], :from => :tophat, :to=> :cuffdiff

module Bio
  module Ngs
    module FS


      CATEGORIES ={
            :cufflinks=>{rules:[/genes\.fpkm_traking/, #same for denovo
                         /isoforms\.fpkm_traking/, #same for denovo
                         /transcripts\.gtf/, #same for denovo
                         /skipped\.gtf/,
                         /genes\.fpkm_tracking/,
                         /isoforms\.fpkm_tracking/]}, #same for denovo
              
            :cuffdiff=>{rules:[/.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*cds\.diff/,
                        /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*cds_exp\.diff/,
                       /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*cds\.fpkm_tracking/,
                       /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*gene_exp\.diff/,
                       /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*genes\.fpkm_tracking/,
                       /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*isoform_exp\.diff/,
                       /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*isoforms\.fpkm_tracking/,
                       /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*promoters\.diff/,
                       /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*splicing\.diff/,
                       /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*tss_group_exp\.diff/,
                       /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*tss_groups\.fpkm_tracking/]},
            :quantification =>{rules:[/quantification/]},
            :cuffcompare =>{rules:[/.*(compare).*\.tracking/,
                           /.*(compare).*\.combined\.gtf/,
                           /.*(compare).*\.loci/,
                           /.*(compare).*\.stats/]},
            :tophat => {rules:[/accepted_hits\.bam$/,
                        /deletions\.bed/,
                        /insertions\.bed/,
                        /junctions\.bed/,
                        /left_kept_reads\.info/,
                        /right_kept_reads\.info/,
                        /unmapped_left\.fq\.z/,
                        /unmapped_right\.fq\.z/
                        ]},
            :rtfc => {rules:[/_L\d{3,3}_R1_\d{3,3}\.trimmed\.fastq\.gz/]}, #reads_trimmed_forward_chunks
            :rtrc => {rules:[/_L\d{3,3}_R2_\d{3,3}\.trimmed\.fastq\.gz/]}, #reads_trimmed_reverse_chunks
            :rtf => {rules:[/_R1\.trimmed\.fastq\.gz/]}, #reads_trimmed_forward
            :rtr => {rules:[/_R2\.trimmed\.fastq\.gz/]}, #reads_trimmed_reverse
            :rtufc => {rules:[/_L\d{3,3}_R1_\d{3,3}\.unpaired\.fastq\.gz/]}, #reads_trimemd_unpaired_forward_chunks
            :rturc => {rules:[/_L\d{3,3}_R2_\d{3,3}\.unpaired\.fastq\.gz/]}, #reads_trimmed_unpaired_reverse_chunks
            :rtuf => {rules:[/_R1\.unpaired\.fastq\.gz/]}, #reads_trimmed_unpaired_forward
            :rtur => {rules:[/_R2\.unpaired\.fastq\.gz/]}, #reads_trimmed_unpaired_reverse
            :rfc => {rules:[/_L\d{3,3}_R1_\d{3,3}\.fastq\.gz/]}, #reads_forward_chunks
            # elsif file=~/trimmed/ && file=~/_L\d+_R._\d+\./
            #   :trimmed_splitted
            # elsif file=~/trimmed/ 
            #   :trimmed
            :rrc => {rules:[/_L\d{3,3}_R2_\d{3,3}\.fastq\.gz/]}, #reads_reverse_chunks                
            :rf => {rules:[/_R1\.fastq\.gz/]}, #reads_forward  
            :rr => {rules:[/_R2\.fastq\.gz/]}, #reads_reverse                
            :logs => {rules:[/logs/]},
            :denovo => {rules:[/denovo/]},
            :rawdata => {rules:[/raw_data/,/rawdata/]},
            :mapquant => {rules:[/MAPQUANT/]},
            :mapquant_projects => {rules:[/MAPQUANT_Projects/]},
            :project => {rules:[/Project_/], action:Proc.new{|file_name| $1.to_sym if file_name=~/Project_(.*?)\//}},
            :sample => {rules:[/Sample_/], action:Proc.new{|file_name| $1.to_sym if file_name=~/Sample_(.*?)\//}},
            :sample_sheet => {rules:[/SampleSheet.csv/]}
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


# x=Bio::Ngs::FS::Project.discover("test/data/DemoHuman/", :excludes=>[/annotation/,/log/]); nil
          def discover(path, options={})
            data = Hash.new { |hash, key| hash[key] = []  }
            # puts path
            Dir.glob(File.join(path,"**/*/**/*")).each do |file|
              #puts file if file=~/Project_Naive\//
              if (File.file?(file) && !path_has_regexps?(file, options[:excludes]))
                type = file_type(file)

                data[file.to_sym]=type
              end
            end
            data.select do |file_tag|
              !data[file_tag].empty?
            end
          end

#input is coming from discover output
# i=Bio::Ngs::FS::Project.index(x); nil
          def index(data)
            indexH = Hash.new { |hash, key| hash[key] = []  }
            data.each_pair do |filename, tags|
              tags.each do |tag|
                if tag.is_a? Symbol
                  indexH[tag] << filename
                elsif tag.is_a? Hash
                  tag.each_pair do |sub_key, sub_value|
                    #key = tag.keys.first
                    #value = tag[key]
                    value = sub_key
                    indexH[sub_key] << sub_value #in case of project and sample it store (samples|projects) [(samples|projects)_name]
                    indexH[sub_value]<< filename #stores for each (sample|project) name its filename so i can search directly for its name
                  end
                end
              end  #tags
            end #data
            indexH.each_pair do |key, value|
              indexH[key].uniq!
            end
          end #index

#input is an index coming from index
          def search(index, *criteria)
            # results = []
            unless criteria.size == 0
              results = index[criteria.shift.to_sym].flatten
              criteria.inject(results) do |r, criterion|
                if criterion_components=composed_criterion?(criterion)
                  r & composed_search(index, criterion_components[0], criterion_components[1])
                else
                  (r & index[criterion.to_sym].flatten) unless index[criterion.to_sym].nil?
                end
              end
              
              # results = index[criteria.shift].flatten
              # criteria.each do |criterion|
              #   results = (results & index[criterion].flatten) unless index[criterion].nil?
              # end #criteria
              # # results.flatten.uniq
              # results
            end
          end

          def composed_criterion?(item)
            if item.is_a?(String) && (ary=item.split(':')).size > 2
              ['-','|','&'].include?(ary.first) && ary.size > 2
              [ary.shift, ary]
            end
          end

          def composed_search(index, operator, criteria)
            results = []
            unless (criteria.size < 2) && ['-','|','&'].include?(operator)
              x=criteria.shift
              results = index[x.to_sym].flatten
              criteria.inject(results) do |r, criterion|
                r.send(operator, index[criterion.to_sym].flatten) unless index[criterion.to_sym].nil?
              end #criteria
            end
          end #search



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
                # puts info.inspect
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

            # puts File.join(path)
            data = aggregate_by_topic(search_path(path,opts), opts)
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

              Thor::CoreExt::HashWithIndifferentAccess.new data
            end

          end #smart_path

          #path is an array of path to be concatenated with File.join
          def search_path(path, opts={})
            if opts[:files]
              path<<"**/*"
            end
            glob = Dir.glob(File.join(path))
            skip_type  = opts[:files] ? :file? : :directory?
            selected_glob =  glob.select do |item|
              File.send skip_type, item
            end
            skip_temp(selected_glob)
          end


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

          def aggregate_by_topic(paths=[], opts={})
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

          #file type form filename
          def file_type(file)
            CATEGORIES.select do |tag|
              path_has_regexps?(file,CATEGORIES[tag][:rules])
            end.map do |tag|
              if tag[1].key?(:action)
                {tag[0]=>tag[1][:action].call(file)}
              else
                tag[0]
              end
            end
          end

          def skip_temp(files=[])
            # files.select do |file_path|
            #   !(file_path=~/[T|t]emp/)
            # end
            skip_files_by_match(files, [/[T|t]emp/])
          end #skip_temp

          def skip_file_by_match(file, regexps=[])
            regexps.any? do |regexp|
              file =~ regexp
            end
          end #skip_file_by_match

          def skip_files_by_match(files=[], regexps=[] )
            files.select do |file|
              !skip_file_by_match(file, regexps)
            end
          end

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




