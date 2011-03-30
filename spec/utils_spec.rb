#
#  converter_qseq_spec.rb - RSpec Test
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#


require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Utils" do
  it "tags the regular file name with the new tag and extension" do
    Bio::Ngs::Utils.tag_filename("test_file_name.txt", "report", "csv").should == "test_file_name_report.csv"    
  end
  
  it "tags the strange file name with the new tag and extension" do
    Bio::Ngs::Utils.tag_filename("test_file_name", "report", "csv").should == "test_file_name_report.csv"    
  end
  
end