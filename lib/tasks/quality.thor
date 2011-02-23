class Quality < Thor
  
  desc "reads FASTQ", "perform quality check for NGS reads"
  def reads(fastq)
    reads = Bio::NGS::FastQuality.new(fastq)
    puts reads.quality_profile
  end
  
end