@TestDirectory = File.expand_path(File.join(File.dirname(__FILE__) + '/../../'))

require File.expand_path(File.join(@TestDirectory, 'spec_helper'))

describe "File System utilities for BioNGS" do 

 before(:each) do
    @data_dir = File.join(File.expand_path(File.join(File.dirname(__FILE__) + '/../../')), 'fixture')
  end


describe Bio::Ngs::FS, ".cat" do
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


describe Bio::Ngs::FS, ".files" do
  context "when input is a string" do
    context "representing an existing file" do
        it "gives back an array with the file name" do
          Bio::Ngs::FS.files(File.join(@data_dir, "test-filtered-reference.fastq.gz")).should =~ [File.join(@data_dir, "test-filtered-reference.fastq.gz")]
        end
    end    
    context "representing a non existing file" do
        it "gives back nil" do
          Bio::Ngs::FS.files(File.join(@data_dir, "fake.file")).should be_nil
        end
    end    
    context "representing a regular expression and there is not subdirectory in the path" do
        it "gives back an array of file names" do
          Bio::Ngs::FS.files(File.join(@data_dir, "*reference*")).should =~ [File.join(@data_dir, "test-filtered-reference.fastq.gz"), File.join(@data_dir, "test-merged-reference.fastq.gz")]
        end
    end    
    context "representing a regular expression and there are subdirectories in the path" do
        it "gives back an array of file names without single subdirectories names" do
          Bio::Ngs::FS.files(File.join(@data_dir,"../", "*spec*")).should =~ %w(converter_qseq_spec.rb cufflinks_spec.rb 
                                                                                quality_spec.rb sff_extract_spec.rb spec_helper.rb 
                                                                                tophat_spec.rb utils_spec.rb).map{|item| File.expand_path(File.join(@data_dir,"../", item))  }
        end
    end    
    context "representing a regular expression and there are subdirectories in the path to be traversed" do
        it "gives back an array of file names without single subdirectories names" do
          Bio::Ngs::FS.files(File.join(@data_dir,"../", "**/*.fastq")).should =~ %w(s_1_1_1108_qseq.fastq test.fastq).map{|item| File.expand_path(File.join(@data_dir, item))}
        end
    end    
    context "representing the local directory lib" do
        it "gives back an array of file names in it" do
          Bio::Ngs::FS.files("lib").should =~ %w(bio-ngs.rb development_tasks.rb enumerable.rb wrapper.rb).map{|item| File.expand_path(File.join(@data_dir,"../../lib/", item))}
        end
    end
    context "representing the local directory lib with a specific suffix" do
        it "gives back an array of file names in lib with suffix spec.rb" do
          Bio::Ngs::FS.files("spec/fixture", ".fastq").should =~ %w(test.fastq s_1_1_1108_qseq.fastq).map{|item| File.expand_path(File.join(@data_dir, item))}
        end
    end    
  end 
end #.files

describe Bio::Ngs::FS::Project, ".projects" do
  context "when requests for all projects" do
    context "but not for files" do
      it "gives back the list of all the projects" do
        x = Bio::Ngs::FS::Project.projects
         x.keys.should be_nil
      end
    end
  end

end


end #File System utilities for BioNGS
