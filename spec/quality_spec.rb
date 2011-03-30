#
#  tophat_spec.rb - RSpec Test
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#


require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "When quality is read" do
  it "should give me back the quality scores of first read in Illumina 1.5+ encoding" do
    read = Bio::FlatFile.auto(File.dirname(__FILE__) + "/fixture/test.fastq").first
    read.format = :fastq_illumina
    qual = read.quality_scores
    qual.should == [39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 37, 39, 39, 39, 39, 39, 38, 38, 39, 39, 37, 39, 39, 37, 39, 39, 39, 37, 33, 39, 39, 37, 30, 39, 39, 36, 34, 35, 39, 39, 39, 35, 36, 39, 37, 36, 37, 39, 38, 39, 39, 38, 38, 38, 38, 30, 38, 38, 38, 38, 37, 38, 36, 37, 37, 26, 37, 38, 35, 35, 35, 37, 39]
  end

  it "should give me back the quality scores of last read, with Bs in Illumina 1.5+ encoding" do
    quals = []
    Bio::FlatFile.auto(File.dirname(__FILE__) + "/fixture/test.fastq").each do |read|
      read.format = :fastq_illumina
      quals = read.quality_scores
    end
    quals.should == [27, 24, 19, 26, 7, 24, 16, 19, 11, 16, 10, 16, 16, 29, 20, 23, 17, 18, 6, 18, 8, 24, 23, 28, 23, 24, 24, 24, 29, 16, 21, 24, 27, 23, 31, 30, 18, 30, 27, 24, 18, 14, 18, 25, 22, 29, 30, 25, 27, 29, 21, 21, 14, 18, 20, 29, 24, 31, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
  end

  it "should tell me how many B are in the sequence with Illumina 1.5+ encoding" do
    reads = Bio::Ngs::FastQuality.new(File.dirname(__FILE__) + "/fixture/test.fastq")
    reads.quality_profile.should == nil
  end
  
  it "should return the comulative count of Bs in all the sequences" do
    reads = Bio::Ngs::FastQuality.new(File.dirname(__FILE__) + "/fixture/test.fastq", :fastq_illumina)
#    reads = Bio::Ngs::FastQuality.new("/Users/bonnalraoul/Desktop/s_1_1_1108_qseq.fastq", :fastq_illumina)
    reads.track_b_count.b_profile.should == [[58, 1], [59, 1], [60, 1], [61, 1], [62, 1], [63, 1], [64, 1], [65, 1], [66, 1], [67, 1], [68, 1], [69, 1], [70, 1], [71, 1], [72, 1], [73, 1], [74, 1], [75, 1]]
  end
end