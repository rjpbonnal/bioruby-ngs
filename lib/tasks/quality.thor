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
    Bio::Ngs::Graphics.draw_area(qual,options[:width],options[:height],options[:fileout])
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
end