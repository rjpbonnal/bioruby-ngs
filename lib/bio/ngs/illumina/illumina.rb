#TODO: refactor this code, I don't like it very much
#TODO: export in JSON format
require 'bio/ngs/illumina/project'
require 'bio/ngs/illumina/sample'
require 'bio/ngs/illumina/fastq'

module Bio
  module Ngs
    module Illumina
    	# class ReadsFile
    	# 	def initialize(name)
    	# 		@name = name
    	# 		set_type(name)
    	# 	end
    	# end

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
    		    project = Project.new(project_dir.sub(/Project_/,""),path)
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





