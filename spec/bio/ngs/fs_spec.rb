@TestDirectory = File.expand_path(File.join(File.dirname(__FILE__) + '/../../'))

require File.expand_path(File.join(@TestDirectory, 'spec_helper'))

describe "File System utilities for BioNGS" do 

 before(:each) do
    @data_dir = File.join(File.expand_path(File.join(File.dirname(__FILE__) + '/../../')), 'fixture')
  end


describe Bio::Ngs::FS, "::cat" do
  it "concatenates the content of multiple files in just one file" do
  	fn_one=File.join(@data_dir, 'test.fastq.gz')
  	fn_two=File.join(@data_dir, 'test-filtered-reference.fastq.gz')
  	fn_merged=File.join(@data_dir, 'test-merged.fastq.gz')
  	fn_merged_reference=File.join(@data_dir, 'test-merged-reference.fastq.gz')
    Bio::Ngs::FS.cat([fn_one, fn_two], fn_merged)

    fmerged_reference=File.open(fn_merged_reference,"rb:binary").read
    fmerged=File.open(fn_merged, "rb:binary").read
    fmerged.to_s.should == fmerged_reference.to_s
  end
end


end #File System utilities for BioNGS
