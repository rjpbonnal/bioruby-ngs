module Bio
  module Ngs
    module Illumina
      module Utils
        
  # desc "aggregate_run DIR [OUTDIR]", "create a single file (forward/reverse) from chucks of a sample in a project"
  def aggregate_run(dir, opt={} )
    outdir = Dir.pwd if opt[:outdir]
    projects = Bio::Ngs::Illumina.build(dir)
    project=projects.each_project do |project_name, project|
      aggregate_project(dir, project_name, opt)
    end
  end


  def aggregate_project(dir, project_name, opt={})
    outdir = Dir.pwd if opt[:outdir]
    projects = Bio::Ngs::Illumina.build(dir)
    project=projects.get(project_name)
    project.each_sample do |sample_name,sample|
      aggregate_sample(dir, project_name, sample_name, opt)
    end
  end

  def aggregate_sample(dir, project_name, sample_name, opt={})
    outdir = Dir.pwd if opt[:outdir]
    projects=Bio::Ngs::Illumina.build(dir)
    project = projects.get(project_name)
    
    if project
      sample = project.get(sample_name)
      if sample
        sample_base_name = File.join(projects.path, project.path, sample.path)
        file_names_forward = Dir.glob(File.join(sample_base_name, "*R1_[0-9][0-9][0-9].fastq.gz")).sort.join(" ")
        file_names_reverse = Dir.glob(File.join(sample_base_name, "*R2_[0-9][0-9][0-9].fastq.gz")).sort.join(" ")
        file_merge_forward = "#{sample.path}_R1.fastq.gz"
        file_merge_reverse = "#{sample.path}_R2.fastq.gz"
        dest_dir = outdir
        if outdir
          Dir.chdir(outdir) do
            rel_projects_path = File.basename(projects.path)
            puts rel_projects_path
            Dir.mkdir(rel_projects_path) unless Dir.exists?(rel_projects_path)
            puts File.join(rel_projects_path,project.path)
            Dir.mkdir(File.join(rel_projects_path,project.path)) unless Dir.exists?(File.join(rel_projects_path,project.path))
            puts File.join(rel_projects_path,project.path, sample.path)
            Dir.mkdir(File.join(rel_projects_path,project.path, sample.path)) unless Dir.exists?(File.join(rel_projects_path,project.path, sample.path))
            dest_dir = File.join(rel_projects_path,project.path, sample.path)
          end 
        end 
        Parallel.map([[file_names_forward, file_merge_forward], [file_names_reverse, file_merge_reverse]], in_processes:3) do |data|
          # puts "destdir #{dest_dir}"
          # puts "filename #{data.last}"
          # puts "input files #{data.first}"
          `zcat #{data.first} | pigz -p #{options[:cpus]} > #{File.join(outdir,dest_dir,data.last)}`
        end
      else
        puts "Sample #{sample_name} does not exist."
      end
    else
      puts "Project #{project_name} does not exist."
    end
  end
end #Utils
end #Illumina
end #Ngs
end #Bio
