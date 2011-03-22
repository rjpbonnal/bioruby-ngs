#
#  converter_qseq_spec.rb - RSpec Test
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#


require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Converter" do 
  describe "Qseq" do
    it "convert two qseq lines into fastq" do
      qseq = Bio::Ngs::Converter::Qseq.new(:pe)
      qseq.buffer = "H125    98      1       1108    1586    1989    CGATGT  1       CAGA.C.................A.....GAATGGCATGGATCAAGAAAATCCCCCTTGTGAAGAAGAATCAGCAG    BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB    0\nH125    98      1       1108    1188    2036    CGATGT  1       CTTGTATGCAGCATCCCCTTCTTGCCTAGGGACTTGAAGGGCCAGGCTTCCTGTCATTGCCTCACTCAAATGTAGC    gggggggggggggegggggffggeggegggeagge^ggdbcgggcdgedegfggffff^ffffefdeeZefccceg    1"
      fastqs = []
      qseq.to_fastq do |fastq|
        fastqs << fastq if fastq
      end
      fastqs.first.should == "@H125:1:1108:1188:2036#0/1\nCTTGTATGCAGCATCCCCTTCTTGCCTAGGGACTTGAAGGGCCAGGCTTCCTGTCATTGCCTCACTCAAATGTAGC\n+\ngggggggggggggegggggffggeggegggeagge^ggdbcgggcdgedegfggffff^ffffefdeeZefccceg"
    end
    
    it "convert a qseq File into fastq for parierd ends" do
      qseq = Bio::Ngs::Converter::Qseq.new(:pe)
      buffer_filename = File.dirname(__FILE__) + "/fixture/s_1_1_1108_qseq.txt"
      fastq_filename  = File.dirname(__FILE__) + "/fixture/s_1_1_1108_qseq.fastq"
      qseq.buffer = File.open(buffer_filename,'r')
      fastq_file = File.open(fastq_filename, 'w')
      qseq.to_fastq do |fastq|
        fastq_file.puts fastq if fastq
      end
      fastq_file.close
      fastq_file = File.open(fastq_filename, 'r')
      fastq_file.readlines[0..4].join("").should == "@H125:1:1108:1188:2036#0/1\nCTTGTATGCAGCATCCCCTTCTTGCCTAGGGACTTGAAGGGCCAGGCTTCCTGTCATTGCCTCACTCAAATGTAGC\n+\ngggggggggggggegggggffggeggegggeagge^ggdbcgggcdgedegfggffff^ffffefdeeZefccceg\n"
      fastq_file.close
      File.delete(fastq_filename)
    end    
  end
end
