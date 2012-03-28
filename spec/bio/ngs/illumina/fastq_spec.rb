# fastq_spec.rb
#require 'bio/ngs/illumina/fastq'
@TestDirectory = File.expand_path(File.join(File.dirname(__FILE__) + '/../../../'))

require File.expand_path(File.join(@TestDirectory, 'spec_helper'))


describe "Illumina Fastq compressed with Gzip" do 

 before(:each) do
    @data_dir = File.join(File.expand_path(File.join(File.dirname(__FILE__) + '/../../../')), 'fixture')
  end


describe Bio::Ngs::Illumina::FastqGz, "::gets_uncompressed" do
  it "returns reads from Illumina fastq compressed archive" do
  	ftest=File.join(@data_dir, 'test.fastq.gz')
    n_reads = Bio::Ngs::Illumina::FastqGz.gets_uncompressed(ftest) do |read_header, reader_seq, read_splitter, read_qual|
      read_header
    end
     n_reads.should be 10
  end
end

describe Bio::Ngs::Illumina::FastqGz, "::gets_filtered" do
  it "returns the filterd reads from Illumina" do
  	reads_header = ""
  	ftest=File.join(@data_dir, 'test.fastq.gz')
    n_reads = Bio::Ngs::Illumina::FastqGz.gets_filtered(ftest) do |read_header, reader_seq, read_splitter, read_qual|
      reads_header+=read_header
    end
    reads_header.should eq "@H125:125:D0C0DACXX:5:1307:20682:66201 1:N:0:ATCACG\n@H125:125:D0C0DACXX:5:1307:20749:66215 1:N:0:ATCACG\n@H125:125:D0C0DACXX:5:1307:20707:66224 1:N:0:ATCACG\n@H125:125:D0C0DACXX:5:1307:20846:66039 1:N:0:ATCACG\n@H125:125:D0C0DACXX:5:1307:20878:66172 1:N:0:ATCACG\n@H125:125:D0C0DACXX:5:1307:20854:66177 1:N:0:ATCACG\n@H125:125:D0C0DACXX:5:1307:20830:66194 1:N:0:ATCACG\n@H125:125:D0C0DACXX:5:1307:20773:66233 1:N:0:ATCACG\n@H125:125:D0C0DACXX:5:1307:21088:66002 1:N:0:ATCACG\n"
    n_reads.should be 9
  end
end

describe Bio::Ngs::Illumina::FastqGz, "::gets_compressed" do
  it "returns compressed reads by Gzip" do
  	reads=[]
  	ftest=File.join(@data_dir, 'test.fastq.gz')
  	ftest_filtered=File.join(@data_dir, 'test-filtered.fastq.gz')
    Bio::Ngs::Illumina::FastqGz.gets_compressed(ftest_filtered) do |compress|
    	Bio::Ngs::Illumina::FastqGz.gets_filtered(ftest) do |read_header, reader_seq, read_splitter, read_qual|
          compress.write(read_header + reader_seq + read_splitter + read_qual)
    	end
    end #compress
    #TODO: test
  end
end


end #"Illumina Fastq compressed with Gzip"