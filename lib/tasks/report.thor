require File.expand_path(File.dirname(__FILE__) + '/../bio/ngs/utils')
require File.expand_path(File.dirname(__FILE__) + '/../wrapper')

class Report < Thor

  class Illumina < Thor

  desc "projects_stats", "Reports quality of FASTQ files in an Illumina project directory"
  method_option :cpus, :type=>:numeric, :default=>4, :aliases=>'-c', :desc=>'Number of processes to use.'
  def illumina_projects_stats(directory=".")
    if File.directory?(directory) && Bio::Ngs::Illumina.project_directory?(directory)
      projects = Bio::Ngs::Illumina.build(directory)
      files = []
      projects.each do |project_name, project|
        project.samples.each do |sample_name, sample|
          #reads_file is an hash with right or left, maybe single also but I didn't code anything for it yet.
          #TODO: refactor these calls
          
          files<<File.join(directory, reads_file[:left]) if reads_file.key?(:left)
          files<<File.join(directory, reads_file[:right]) if reads_file.key?(:right)
        end
      end
      Parallel.map(files, in_processes:options[:cpus]) do |file|
        fastq_stats file
      end
    else
      STDERR.puts "illumina_projects_stats: Not an Illumina directory"
    end
  end #illumina_projects_stats


  desc "number_of_reads FILE", "return the number of reads in the fastq.gz file"
  def number_of_reads(file)
    puts Bio::Ngs::Illumina::FastqGz.gets_filtered(file)
  end


  end #Illumina
end


#compute trimmed file total size
#Dir.glob("**/**/*trimmed.fastq.gz").inject(0){|s,i| s+=File.size(i)}/(1024.0 * 1024.0 * 1024.0)