#
#  
#
# Copyright:: Copyright (C) 2011
#     Francesco Strozzi <francesco.strozzi@gmail.com>
# License:: The Ruby License
#
#


class Bwa < Thor
  
  desc "index [FASTA]", "Create BWA index"
  Bio::Ngs::Bwa::Index.new.thor_task(self, :index) do |wrapper, task, file_in|
    wrapper.params = task.options
    puts wrapper.run :arguments => [file_in]
  end

  desc "aln [PREFIX] [FASTA/Q]", "Run BWA aln (short reads)"
  Bio::Ngs::Bwa::Aln.new.thor_task(self, :aln) do |wrapper, task, prefix, file_in|
    wrapper.params = task.options
    puts wrapper.run :arguments => [prefix,file_in]
  end
  
  desc "samse [PREFIX] [SAI FILE] [FASTA/Q FILE]", "Run BWA SAM Single End conversion"
  Bio::Ngs::Bwa::Samse.new.thor_task(self, :samse) do |wrapper, task, prefix, sai_in, file_in|
    wrapper.params = task.options
    puts wrapper.run :arguments => [prefix,sai_in,file_in]
  end
  
  desc "sampe [PREFIX] [SAI-1 FILE] [SAI-2 FILE] [FASTA/Q-1 FILE] [FASTA/Q-2 FILE]", "Run BWA SAM Paired End conversion"
  Bio::Ngs::Bwa::Sampe.new.thor_task(self, :sampe) do |wrapper, task, prefix, sai1_in, sai2_in, file1_in, file2_in|
    wrapper.params = task.options
    puts wrapper.run :arguments => [prefix, sai1_in, sai2_in, file1_in, file2_in]
  end
  
  desc "bwasw [PREFIX] [FASTA/Q]", "Run BWA bwasw (long reads)"
  Bio::Ngs::Bwa::Bwasw.new.thor_task(self, :bwasw) do |wrapper, task, prefix, file_in|
    wrapper.params = task.options
    arguments = [prefix,sai_in,file_in]
    arguments+[task.options[:paired]] if task.options[:paired] =~/\w+/
    puts wrapper.run :arguments => arguments
  end

  desc "fastmap [PREFIX] [FASTA/Q]", "Run BWA Fastmap (identify super-maximal exact matches)"
  Bio::Ngs::Bwa::Fastmap.new.thor_task(self, :fastmap) do |wrapper, task, prefix, file_in|
    wrapper.params = task.options
    puts wrapper.run :arguments => [prefix,file_in]
  end


end