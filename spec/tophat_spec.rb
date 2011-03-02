require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'thor/base'
#require 'bio/appl/ngs/tophat'

describe "Tophat with include" do 
  describe "Options" do
    it "default" do
      Bio::Ngs::Tophat.new.options.should == ""      
    end
  end
  
  describe "Program name" do
    it "the name is " do
      Bio::Ngs::Tophat.program.should == ""
    end
  end
end


# describe Tophat do
#   describe "Tophat" do
#     it "the program is " do
#       Bio::Ngs::Tophat.new.program.should == Bio::Ngs::Utils.os_binary("tophat/tophat")
#     end
#     
#     it "returns the default parameters" do
#       Bio::Ngs::Tophat.new.main.should == ""
#     end
#     
#     it "all the parameters of this application" do 
#       first_option = Bio::Ngs::Tophat.tasks["main"].options.first #is an array of name, Thor::Option
#       thor_option = first_option.last
#       thor_option.name.should == "reads"
#     end
#     
#   end
# end
