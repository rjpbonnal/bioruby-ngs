#TODO: refactor this code, I don't like it very much
#TODO: export in JSON format
module Bio
  module Ngs
    module Illumina
    	# class ReadsFile
    	# 	def initialize(name)
    	# 		@name = name
    	# 		set_type(name)
    	# 	end
    	# end
    	class Sample
    		attr_accessor :name, :filenames
    		def initialize(name, parent=nil)
    		  @name = name
    		#  @paired = nil
    		  @filenames =  Hash.new {|hash,key| hash[key] = {left:false,right:false,index:nil,zipped:false,chunks:[]}} # {name=>{:right=>string, :left=>string, :single=>string, :zipped=>(true|false), :index=>string, :chunk=>(001,002,003,...)}, ...}
    		  @parent = parent
    		end

    		def path
    		  File.join @parent.path,"Sample_#{name}"
    		end

    		def paired?
    		  @filenames.key?(:left) && @filenames.key?(:right)
    		end

    		def add_filename(filename)
    		  filename_cleaned = filename.sub(/_R.*/,'')
    		  if filename=~/.*_R1_.*/
                @filenames[filename_cleaned][:left]=true
              elsif filename=~/.*_R2_.*/
            	@filenames[filename_cleaned][:right]=true
              end
                	
              if filename=~/\.gz/
              	@filenames[filename_cleaned][:zipped]=true
              # elsif filename=~/\.fastq$/
              # 	@filenames[filename_cleaned][:zipped]=false
              end

              if filename=~/R._(\d*).fastq(.gz)?/
              	@filenames[filename_cleaned][:chunks]<<$1 unless @filenames[filename_cleaned][:chunks].include?($1)
              end	
    		end

    		def filename_path(name)
    		  if @filenames.key?(name)
    		  	data = @filenames[name]
    		  	results=data[:chunks].map do |chunk|
    		  		subdata={}
    		      subdata[:left]=File.join(path, "#{name}_R1_#{chunk}.fastq" )  if data.key?(:left)
    		      subdata[:right]=File.join(path, "#{name}_R2_#{chunk}.fastq" )  if data.key?(:right)
    		      subdata
    		    end
    		    if data[:zipped]
    		      results.each_index do |idx|
    		        results[idx][:left]="#{results[idx][:left]}.gz" if data.key?(:left)
    		        results[idx][:right]="#{results[idx][:right]}.gz" if data.key?(:right)
    		      end
    		    end
    		  end
    		end

    		def filenames_paths
    			@filenames.keys.map do |filename|
    				filename_path(filename)
    			end.flatten
    		end
    	end

    	class Project
    		attr_accessor :samples, :name, :sample_sheet
    		def initialize(name, root_dir=".")
    			@name = name
    			@samples = {}
    			@sample_sheet = nil
    			@root_dir = root_dir
    		end

    		def path
              File.join(@root_dir, (name=~/Undetermined_indices/ ? name : "Project_#{name}"))
    		end

    		def samples_path
    			@samples.each_key.map do |sample_name|
    				@samples[sample_name].filenames_paths
    			end.flatten
    		end
    	end

    	require 'find'
    	class << self
    		def project_directory?(path=".")
    		  Dir.chdir(path) do	
               projects = Dir.glob(["Project_*","Undetermined_indices"])
               return false if projects.empty?
               into_projects = projects.map do |project|
                 Dir.chdir(project) do |sample|
                 	Dir.glob("Sample*").size>0
                 end
               end.uniq

               if (into_projects.size>1 || (into_projects.first==false))
               	return false
               end
              end
               true
    		end

    		def build(path=".")
    		 Dir.chdir(path) do
    		  Dir.glob(["Project_*","Undetermined_indices"]).inject({}) do |projects, project_dir|
    		    project = Project.new(project_dir.sub(/Project_/,""))
                projects[project.name] = project
    			Dir.chdir(project_dir) do
                  Dir.glob("Sample*").each do |sample_dir|
                    sample = Sample.new(sample_dir.sub(/Sample_/,""), project)
                    project.samples[sample.name] = sample
                    Dir.chdir(sample_dir) do
                      Dir.glob(["*.fastq", "*.fastq.gz"]) do |reads_filename|
                        sample.add_filename(reads_filename)
                      end
                    end
                  end
    			end
    			projects
    	      end
    	     end
    		end
    	end
    end #Illumina
  end #Ngs
end #Bio	





