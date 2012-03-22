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
    go_in_parallel = [[:boxplot,[output_file]],
                      [:reads_coverage,[output_file]],
                      [:nucleotide_distribution,[output_file]]]
    Parallel.map(go_in_parallel, in_processes:go_in_parallel.size) do |graph|
      invoke graph.first, graph.last
    end
  end
  
  desc "illumina_project_stats", "Reports quality of FASTQ files in an Illumina project directory"
  method_option :cpus, :type=>:numeric, :default=>4, :aliases=>'-c', :desc=>'Number of processes to use.'
  def illumina_projects_stats(directory=".")
    if File.directory?(directory) && Bio::Ngs::Illumina.project_directory?(directory)
      projects = Bio::Ngs::Illumina.build(directory)
      files = []
      projects.each do |project_name, project|
        project.samples_path.each do |reads_file|
          #reads_file is an hash with right or left, maybe single also but I didn't code anything for it yet.
          #TODO: refactor these calls
          
          files<<[File.join(directory, reads_file[:left])] if reads_file.key?(:left)
          files<<[File.join(directory, reads_file[:right])] if reads_file.key?(:right)
        end
      end
      Parallel.map(files, in_processes:options[:cpus]) do |file|
        invoke :fastq_stats, file
      end
    else
      STDERR.puts "illumina_projects_stats: Not an Illumina directory"
    end
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
  def scatterplot (expr1, expr2, output)
                                                                                                  
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
end


