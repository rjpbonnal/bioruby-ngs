# illumina_spec.rb
@TestDirectory = File.expand_path(File.join(File.dirname(__FILE__) + '/../../../'))

require File.expand_path(File.join(@TestDirectory, 'spec_helper'))


describe "Illumina" do 

 before(:each) do
    @data_dir = File.join(File.expand_path(File.join(File.dirname(__FILE__) + '/../../../../')), 'test', 'data')
  end


describe Bio::Ngs::Illumina, ".build" do
  it "returns an array of projects" do
  	projects = Bio::Ngs::Illumina.build(@data_dir)
    projects.should be nil
  end
end

end #"Illumina Fastq compressed with Gzip"