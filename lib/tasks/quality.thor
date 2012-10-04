#
#  
#
# Copyright:: Copyright (C) 2011
#     Francesco Strozzi <francesco.strozzi@gmail.com>
# License:: The Ruby License
#
#

class Quality < Thor

  desc "reads FASTQ", "perform quality check for NGS reads"
  method_option :width, :type => :numeric, :default => 500
  method_option :height, :type => :numeric, :default => 500
  method_option :fileout, :type => :string, :default => "fastq_report.svg"  
  def reads(fastq)
    reads = Bio::Ngs::FastQuality.new(fastq)
    qual = reads.quality_profile
    Bio::Ngs::Graphics.draw_area(qual,options[:width],options[:height],options[:fileout],"Nucleotide","Quality Score")
  end

  desc "quality_trim FASTQ", "Trim all the sequences using quality information"
  #TODO: create a wrapper
  method_option :min_size, :type=>:numeric, :default=>20, :aliases => "-l", :desc=>"Minimum length - sequences shorter than this (after trimming)
                    will be discarded. Default = 0 = no minimum length."
  method_option :min_quality, :type=>:numeric, :default=>10, :aliases => "-t", :desc=>"Quality threshold - nucleotides with lower 
                                      quality will be trimmed (from the end of the sequence)."
  method_option :output, :type=>:string, :aliases => "-o", :desc => "Output file name"
  def quality_trim(fastq)
    output_file = options.output || fastq.gsub(/(.*)_(forward|reverse)(.*)/,'\1_trim_\2\3')
    if output_file==fastq
      output_file+="_trim"
    end
    raise "Input file #{fastq} dosen't exist." unless File.exists?(fastq)
    unless File.exists?("#{fastq}.txt") #suppose there is a stat file for the input file
      invoke :fastq_stats, [fastq]
    end
    #TODO check the file in input exists
    trim = Bio::Ngs::Fastx::QualityTrim.new
    trim.params={min_size:options.min_size, min_quality:options.min_quality, input:fastq, output:output_file}
    trim.run
    invoke :fastq_stats, [output_file]
  end
  
  desc "fastq_stats FASTQ", "Reports quality of FASTQ file"
  method_option :output, :type=>:string, :aliases =>"-o", :desc => "Output file name. default is input file_name with .txt."
  def fastq_stats(fastq)
    uuid = SecureRandom.uuid
    puts "[#{Time.now}] #{uuid} Processing #{fastq} stats"
    output_file = options.output || "#{fastq.gsub(/\.fastq\.gz/,'')}_stats.txt"
    stats = Bio::Ngs::Fastx::FastqStats.new
    if fastq=~/\.gz/
      stats.params = {output:output_file}
      stats.pipe_ahead=["zcat", fastq]
    else
      stats.params = {input:fastq, output:output_file}
    end
    stats.run
    require 'parallel'
    go_in_parallel = [[:boxplot,output_file],
                      [:reads_coverage,output_file],
                      [:nucleotide_distribution,output_file]]
    Parallel.map(go_in_parallel, in_processes:go_in_parallel.size) do |graph|
      puts "[#{Time.now}] #{uuid} Plotting #{graph.first} #{graph.last}"
      send graph.first, graph.last
    end
    puts "[#{Time.now}] Finished #{fastq}"
  end


  desc "boxplot FASTQ_QUALITY_STATS", "plot reads quality as boxplot"
  method_option :title, :type=>:string, :aliases =>"-t", :desc  => "Title (usually the solexa file name) - will be plotted on the graph."
  method_option :output, :type=>:string, :aliases =>"-o", :desc => "Output file name. default is input file_name with .txt."
  def boxplot(fastq_quality_stats)
    output_file = options.output || "#{fastq_quality_stats}_boxplot.png"
    boxplot = Bio::Ngs::Fastx::ReadsBoxPlot.new
    boxplot.params={input:fastq_quality_stats, output:output_file}
    boxplot.run
  end
  
  desc "reads_coverage FASTQ_QUALITY_STATS", "plot reads coverage in bases"
  method_option :title, :type=>:string, :aliases =>"-t", :desc  => "Title (usually the solexa file name) - will be plotted on the graph."
  method_option :output, :type=>:string, :aliases =>"-o", :desc => "Output file name. default is input file_name with .txt."
  def reads_coverage(fastq_quality_stats)
    #TODO: port this script to biongs now is only on my server
    output_file = options.output || "#{fastq_quality_stats}_coverage.png"
    coverage = Bio::Ngs::Fastx::ReadsCoverage.new
    coverage.params={input:fastq_quality_stats, output:output_file}
    coverage.run
  end
  
  desc "nucleotide_distribution FASTQ_QUALITY_STATS", "plot reads quality as boxplot"
  method_option :title, :type=>:string, :aliases =>"-t", :desc  => "Title (usually the solexa file name) - will be plotted on the graph."
  method_option :output, :type=>:string, :aliases =>"-o", :desc => "Output file name. default is input file_name with .txt."
  def nucleotide_distribution(fastq_quality_stats)
    output_file = options.output || "#{fastq_quality_stats}_nuc_dist.png"
    nucdistr = Bio::Ngs::Fastx::NucleotideDistribution.new
    nucdistr.params={input:fastq_quality_stats, output:output_file}
    nucdistr.run
  end

  desc "illumina_b_profile_raw FASTQ", "perform a profile for reads coming fom Illumina 1.5+ and write the report in a txt file"
  method_option :read_length, :type => :numeric, :required => true
  method_option :width, :type => :numeric, :default => 500
  method_option :height, :type => :numeric, :default => 500
  method_option :fileout, :type => :string, :default => "fastq_report.txt"  
  def illumina_b_profile_raw(fastq)
    reads = Bio::Ngs::FastQuality.new(fastq, :fastq_illumina)
    profile = Array.new(options.read_length,0) #create a default profile setted to zero.
    quals = reads.track_b_count
    quals.b_profile.each do |b_item|
      b_index = b_item[0]
      b_count = b_item[1]
      profile[b_index] = b_count if b_index <= options.read_length
    end
    File.open(options.fileout,'w') do |f|
      f.puts "Total reads: #{quals.n_reads}"
      profile.each_index do |index|
        f.puts "#{index},#{profile[index]}"
      end
    end#File
  end

  desc "illumina_b_profile_svg FASTQ", "perform a profile for reads coming fom Illumina 1.5+"
  method_option :read_length, :type => :numeric, :required => true
  method_option :width, :type => :numeric, :default => 500
  method_option :height, :type => :numeric, :default => 500
  method_option :fileout, :type => :string, :default => "fastq_report.svg"  
  def illumina_b_profile_svg(fastq)
    reads = Bio::Ngs::FastQuality.new(fastq, :fastq_illumina)
    profile = Array.new(options.read_length,0) #create a default profile setted to zero.
    reads.track_b_count.b_profile.each do |b_item|
      b_index = b_item[0]
      b_count = b_item[1]
      profile[b_index] = b_count if b_index <= options.read_length
    end

    Bio::Ngs::Graphics.draw_area(profile,options[:width],options[:height],options[:fileout], "B distribution", "Nucleotides", "Counts", n_ticks=30)
  end  

  desc "scatterplot EXPR1 EXPR2 OUTPUT", "plot quantification values as scatterplot in png format"
  method_option :title, :type=>:string, :aliases =>"-t", :desc  => "Title plotted on the graph."
  def scatterplot(expr1, expr2, output)
                                                                                                  
    [expr1, expr2].each do |file_name|                                                            #controllo sul file!
      unless File.exists?(file_name)
             raise "Input file #{file_name} doesn't exist, please insert a valid file name."
      end
    end
    
    system "sort #{expr1} > tmp_1"      #con system richiami la shell
    system "sort #{expr2} > tmp_2"
    File.open("tmp_gnuplot",'w') do |f|
      f.puts "set title '#{options.title || "Scatter plot NGS"}'"
      f.puts "set terminal png"
      f.puts "set output '#{output}.png'"
      f.puts "plot '< join tmp_1 tmp_2 | head -n -1' using 6:14"
    end                                           
    puts "gnuplot tmp_gnuplot"
    system "cat tmp_gnuplot"
    system "rm tmp_1 tmp_2 tmp_gnuplot"    
  end 


  desc "aggregate DIR PROJECT [OUTDIR]", "create a single file (forward/reverse) from chucks of a sample in a project"
  def aggregate(dir, project_name, outdir=nil)
    outdir = Dir.pwd if outdir.nil?
    projects = Bio::Ngs::Illumina.build(dir)
    project=projects.get(project_name)
    project.each_sample do |n,sample|
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
        `zcat #{data.first} | pigz -p 2  > #{File.join(dest_dir,data.last)}`
      end
    end
  end

  desc "aggregate_sample DIR PROJECT SAMPLE [OUTDIR]", "create a single file (forward/reverse) from chucks of a sample in a project"
  def aggregate_sample(dir, project_name, sample_name, outdir=nil)
    outdir = Dir.pwd if outdir.nil?
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
        `zcat #{data.first} | pigz -p 2 > #{File.join(dest_dir,data.last)}`
      end
    else
       puts "Sample #{sample_name} does not exist."
    end
  else
    puts "Project #{project_name} does not exist."
  end
  end

  desc "reads_per_projects_and_samples [DIR]", "count the number of reads for each sample"
  def reads_per_projects_and_samples(dir='.')
    Bio::Ngs::Illumina.build(dir).each do |project_name, project|
      project.each_file do |project, sample, reads|
        nreads = Bio::Ngs::Illumina::FastqGz.gets_uncompressed(File.join(dir, project.path, sample.path, reads.filename)) do
          yield if block_given?
        end
        puts "#{project.name},#{sample.name},#{reads.lane},#{reads.chunks},#{reads.side},#{nreads}"
      end
    end
  end
  
  desc "illumina_projects_stats", "Reports quality of FASTQ files in an Illumina project directory"
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
  end

  desc "trim_momatic_pe FORWARD REVERSE [DESTDIR]", "Trim reads on quality by using Trimmomatic, Paired Ends"
  method_option :threads, :type => :numeric, :default => 2, :desc => 'Number of threads to use by Trimmomatic'
  method_option :log, :type => :string, :desc => 'Log Trimmomatic activities'
  def trim_momatic_pe(forward, reverse, destdir=nil)
    uuid = SecureRandom.uuid
    puts "[#{Time.now}] #{uuid} Start trimming #{forward} and #{reverse} paired end reads by Trimmomatic"
    puts "#{File.dirname(__FILE__)}/../bio/ngs/ext/bin/common/trimmomatic/trimmomatic-0.22.jar"
    # -threads #{options[:threads]} {'-trimlog' if options[:log]} #{options[:log]} 
    forward_filename = File.basename(forward)
    forward_dir = File.dirname(forward)
    reverse_filename = File.basename(reverse)
    reverse_dir = File.dirname(reverse)
    forward_trimmed_filename = File.join( (destdir.nil? ? forward_dir : destdir),forward_filename.gsub(/fastq\.gz/,'trimmed.fastq.gz'))
    reverse_trimmed_filename = File.join( (destdir.nil? ? forward_dir : destdir),reverse_filename.gsub(/fastq\.gz/,'trimmed.fastq.gz'))
    forward_unpaired_filename = File.join( (destdir.nil? ? forward_dir : destdir),forward_filename.gsub(/fastq\.gz/,'unpaired.fastq.gz'))
    reverse_unpaired_filename = File.join( (destdir.nil? ? forward_dir : destdir),reverse_filename.gsub(/fastq\.gz/,'unpaired.fastq.gz'))
    `java -classpath #{File.dirname(__FILE__)}/../bio/ngs/ext/bin/common/trimmomatic/trimmomatic-0.22.jar org.usadellab.trimmomatic.TrimmomaticPE -threads #{options[:threads]} -phred33 #{forward} #{reverse} #{forward_trimmed_filename} #{forward_unpaired_filename}  #{reverse_trimmed_filename} #{reverse_unpaired_filename} LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36`
    puts "[#{Time.now}] #{uuid} Finished "
  end

  desc "illumina_aggregated_sample_trim DIR PROJECT [SAMPLE]", "Trim aggregated data from Illumina project"
  method_option :aggregated, :type => :boolean, :default => true, :desc => 'Process only reads with aggregated by biongs quality:aggregate'
  method_option :threads, :type => :numeric, :default => 2, :desc => 'Number of threads to use by Trimmomatic'
  def illumina_aggregated_sample_trim(directory, project_name, sample_name=nil)
    projects = Bio::Ngs::Illumina.build(directory)
    if (project = projects.get project_name)
      if (sample = project.get sample_name)
        forward = (sample.get :side, :left ).map{|uid, readsfile| readsfile.metadata[:filename]}.first
        reverse = (sample.get :side, :right).map{|uid, readsfile| readsfile.metadata[:filename]}.first
        trim_momatic_pe(File.join(directory,project.path,sample.path,forward), File.join(directory,project.path,sample.path,reverse))
      else
        puts "Sample #{sample_name} does not exist."
      end
    else
      puts "Project #{project_name} does not exist."
    end
  end

  desc "illumina_trim_run DIR","trim all fastq file in projects and samples directories as paired ends" 
  method_option :threads, :type => :numeric, :default => 2, :desc => 'Number of threads to use by Trimmomatic'  
  def illumina_trim_run(directory)
    Bio::Ngs::Illumina.build(directory).each do |project_name, project|
      project.each_sample do |sample_name, sample|
        sample.chunks do |chunk|
          sample.get(:chunks, chunk)

        end
        #forward = (sample.get :side, :left ).map{|uid, readsfile| readsfile.metadata[:filename]}.first
        #reverse = (sample.get :side, :right).map{|uid, readsfile| readsfile.metadata[:filename]}.first
        trim_momatic_pe(File.join(directory,project.path,sample.path,forward), File.join(directory,project.path,sample.path,reverse))
      end
    end
  end

  desc "illumina_sample_aggregate_trim SRCDIR PROJECT SAMPLE", "Aggregate and trim and sample"
  def illumina_sample_aggregate_trim(src_dir, out_dir, project_name, sample_name)
    aggregate_sample(src_dir, project_name, sample_name)
    illumina_aggregated_sample_trim(out_dir, project_name, sample_name)
  end

  desc "list_projects_samples DIR", "list projects and samples in a run"
  def list_projects_samples(directory)
    Bio::Ngs::Illumina.build(directory).each do |project_name, project|
      project.each_sample do |sample_name, sample|
        puts "#{directory} #{project_name} #{sample_name}"
      end
    end
  end


  desc "list_samples DIR PROJECT", "list samples in a project run"
  def list_samples(directory, project_name)
    project = Bio::Ngs::Illumina.build(directory).get project_name
    if project
      project.each_sample do |sample_name, sample|
        puts "#{directory} #{project_name} #{sample_name}"
      end
    else
      puts "Project #{project_name} does not exist."
    end
  end


  desc "clean_from_trimming [DIR]", "remove trimmomatic files from direcoty recursively"
  def clean_from_trimming(dir=".")
    files = Dir.glob(["**/*trimmed*", "**/*unpaired*"])
    files_size = files.inject(0){|c,v| c+=File.size(v)}
    Dir.glob(["**/*trimmed*", "**/*unpaired*"]) do |file|
      File.delete file
    end
    puts "Deleted #{files_size}"
  end

  desc "clean_from_aggregated [DIR]", "remove aggregated files from direcoty recursively"
  def clean_from_aggregated(dir=".")
    files = Dir.glob(["**/*R?\.fastq.gz"])
    files_size = files.inject(0){|c,v| c+=File.size(v)}
    files.each do |file|
      File.delete file
    end
    puts "Deleted #{files_size}"
  end


end
