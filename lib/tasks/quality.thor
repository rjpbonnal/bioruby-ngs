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
  
end