class Quality < Thor
  
  desc "reads FASTQ", "perform quality check for NGS reads"
  def reads(fastq)
    reads = Bio::NGS::FastQuality.new(fastq)
    qual = reads.quality_profile
    Bio::NGS::Graphics.draw_area(qual,500,500,"sample_fastq.svg")
  end
  
end