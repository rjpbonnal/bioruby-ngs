#TODO: refactor this code, I don't like it very much
#TODO: export in JSON format
module Bio
  module Ngs
    require 'json'
    module Illumina
    	class Project
    		attr_accessor :samples, :name, :sample_sheet, :root_dir
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
        def to_json(*a)
          {
             "json_class"    => self.class.name,
             "name"          => name,
             "sample_sheet"  => sample_sheet,
             "samples"       => samples.each_key.map{|k| samples[k].to_json }
          }.to_json(*a)
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
    		    project = Project.new(project_dir.sub(/Project_/,""), path)
                projects[project.name] = project
    			Dir.chdir(project_dir) do
                  Dir.glob("Sample*").each do |sample_dir|
                    sample = Sample.new(sample_dir.sub(/Sample_/,""), project)
                    project.samples[sample.name] = sample
                    Dir.chdir(sample_dir) do
                      Dir.glob(["**/*.fastq", "**/*.fastq.gz"]) do |reads_filename|
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





