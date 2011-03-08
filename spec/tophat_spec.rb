#
#  tophat_spec.rb - RSpec Test
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#


require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Tophat" do 
  describe "class" do
    it "default options" do
      Bio::Ngs::Tophat.options.should == {"output-dir"=>{:type=>:string, :aliases=>"-o"}, "min-anchor"=>{:type=>:numeric, :aliases=>"-a"}, "splice-mismatches"=>{:type=>:numeric, :aliases=>"-m"}, "min-intron"=>{:type=>:numeric, :aliases=>"-i"}, "max-intront"=>{:type=>:numeric, :aliases=>"-I"}, "max-multihits"=>{:type=>:numeric, :aliases=>"-g"}, "min-isoform_fraction"=>{:type=>:numeric, :aliases=>"-F"}, "solexa-quals"=>{:type=>:boolean}, "solexa1.3-quals"=>{:type=>:boolean, :aliases=>"--phred64-quals"}, :quals=>{:type=>:boolean, :aliases=>"-Q"}, "integer-quals"=>{:type=>:boolean}, :color=>{:type=>:boolean, :aliases=>"-C"}, "library-type"=>{:type=>:string}, "num-threads"=>{:type=>:numeric, :aliases=>"-p"}, "GTF"=>{:type=>:string, :aliases=>"-G"}, "raw-juncs"=>{:type=>:string, :aliases=>"-j"}, :insertions=>{:type=>:string}, :deletions=>{:type=>:string}, "mate-inner-dist"=>{:type=>:numeric, :aliases=>"-r"}, "mate-std-dev"=>{:type=>:numeric}, "no-novel-juncs"=>{:type=>:boolean}, "no-gtf-juncs"=>{:type=>:boolean}, "no-coverage-search"=>{:type=>:boolean}, "coverage-search"=>{:type=>:boolean}, "no-closure-search"=>{:type=>:boolean}, "closure-search"=>{:type=>:boolean}, "fill-gaps"=>{:type=>:boolean}, "microexon-search"=>{:type=>:boolean}, "butterfly-search"=>{:type=>:boolean}, "no-butterfly-search"=>{:type=>:boolean}, "keep-tmp"=>{:type=>:boolean}, "tmp-dir"=>{:type=>:string}, "segment-mismatches"=>{:type=>:numeric}, "segment-length"=>{:type=>:numeric}, "min-closure-exon"=>{:type=>:numeric}, "min-closure-intron"=>{:type=>:numeric}, "max-closure-intron"=>{:type=>:numeric}, "min-coverage-intron"=>{:type=>:numeric}, "max-coverage-intron"=>{:type=>:numeric}, "min-segment-intron"=>{:type=>:numeric}, "max-segment-intron"=>{:type=>:numeric}, "rg-id"=>{:type=>:string}, "rg-sample"=>{:type=>:string}, "rg-library"=>{:type=>:string}, "rg-description"=>{:type=>:string}, "rg-platform-unit"=>{:type=>:string}, "rg-center"=>{:type=>:string}, "rg-date"=>{:type=>:string}, "rg-platform"=>{:type=>:string}}     
    end
    
    it "has default program name" do
      Bio::Ngs::Tophat.program.should == Bio::Ngs::Utils.os_binary("tophat/tophat")
    end
  end
  
  describe "instance" do
    it "has default options" do
      Bio::Ngs::Tophat.new.options.should == {"output-dir"=>{:type=>:string, :aliases=>"-o"}, "min-anchor"=>{:type=>:numeric, :aliases=>"-a"}, "splice-mismatches"=>{:type=>:numeric, :aliases=>"-m"}, "min-intron"=>{:type=>:numeric, :aliases=>"-i"}, "max-intront"=>{:type=>:numeric, :aliases=>"-I"}, "max-multihits"=>{:type=>:numeric, :aliases=>"-g"}, "min-isoform_fraction"=>{:type=>:numeric, :aliases=>"-F"}, "solexa-quals"=>{:type=>:boolean}, "solexa1.3-quals"=>{:type=>:boolean, :aliases=>"--phred64-quals"}, :quals=>{:type=>:boolean, :aliases=>"-Q"}, "integer-quals"=>{:type=>:boolean}, :color=>{:type=>:boolean, :aliases=>"-C"}, "library-type"=>{:type=>:string}, "num-threads"=>{:type=>:numeric, :aliases=>"-p"}, "GTF"=>{:type=>:string, :aliases=>"-G"}, "raw-juncs"=>{:type=>:string, :aliases=>"-j"}, :insertions=>{:type=>:string}, :deletions=>{:type=>:string}, "mate-inner-dist"=>{:type=>:numeric, :aliases=>"-r"}, "mate-std-dev"=>{:type=>:numeric}, "no-novel-juncs"=>{:type=>:boolean}, "no-gtf-juncs"=>{:type=>:boolean}, "no-coverage-search"=>{:type=>:boolean}, "coverage-search"=>{:type=>:boolean}, "no-closure-search"=>{:type=>:boolean}, "closure-search"=>{:type=>:boolean}, "fill-gaps"=>{:type=>:boolean}, "microexon-search"=>{:type=>:boolean}, "butterfly-search"=>{:type=>:boolean}, "no-butterfly-search"=>{:type=>:boolean}, "keep-tmp"=>{:type=>:boolean}, "tmp-dir"=>{:type=>:string}, "segment-mismatches"=>{:type=>:numeric}, "segment-length"=>{:type=>:numeric}, "min-closure-exon"=>{:type=>:numeric}, "min-closure-intron"=>{:type=>:numeric}, "max-closure-intron"=>{:type=>:numeric}, "min-coverage-intron"=>{:type=>:numeric}, "max-coverage-intron"=>{:type=>:numeric}, "min-segment-intron"=>{:type=>:numeric}, "max-segment-intron"=>{:type=>:numeric}, "rg-id"=>{:type=>:string}, "rg-sample"=>{:type=>:string}, "rg-library"=>{:type=>:string}, "rg-description"=>{:type=>:string}, "rg-platform-unit"=>{:type=>:string}, "rg-center"=>{:type=>:string}, "rg-date"=>{:type=>:string}, "rg-platform"=>{:type=>:string}}
    end
    
    it "has custom name" do
      Bio::Ngs::Tophat.new("/usr/local/bin/tophat").program.should == "/usr/local/bin/tophat"
    end
    
    it "overwrites specifc option" do
      tophat = Bio::Ngs::Tophat.new
      tophat.options={:reads=>{:type=>:numeric}}
      tophat.options[:reads][:type].should == :numeric
    end
  
    it "add custom option" do
      tophat = Bio::Ngs::Tophat.new
      tophat.options={:parameter_xxx=>{:type=>:numeric}}
      tophat.options.should == {"output-dir"=>{:type=>:string, :aliases=>"-o"}, "min-anchor"=>{:type=>:numeric, :aliases=>"-a"}, "splice-mismatches"=>{:type=>:numeric, :aliases=>"-m"}, "min-intron"=>{:type=>:numeric, :aliases=>"-i"}, "max-intront"=>{:type=>:numeric, :aliases=>"-I"}, "max-multihits"=>{:type=>:numeric, :aliases=>"-g"}, "min-isoform_fraction"=>{:type=>:numeric, :aliases=>"-F"}, "solexa-quals"=>{:type=>:boolean}, "solexa1.3-quals"=>{:type=>:boolean, :aliases=>"--phred64-quals"}, :quals=>{:type=>:boolean, :aliases=>"-Q"}, "integer-quals"=>{:type=>:boolean}, :color=>{:type=>:boolean, :aliases=>"-C"}, "library-type"=>{:type=>:string}, "num-threads"=>{:type=>:numeric, :aliases=>"-p"}, "GTF"=>{:type=>:string, :aliases=>"-G"}, "raw-juncs"=>{:type=>:string, :aliases=>"-j"}, :insertions=>{:type=>:string}, :deletions=>{:type=>:string}, "mate-inner-dist"=>{:type=>:numeric, :aliases=>"-r"}, "mate-std-dev"=>{:type=>:numeric}, "no-novel-juncs"=>{:type=>:boolean}, "no-gtf-juncs"=>{:type=>:boolean}, "no-coverage-search"=>{:type=>:boolean}, "coverage-search"=>{:type=>:boolean}, "no-closure-search"=>{:type=>:boolean}, "closure-search"=>{:type=>:boolean}, "fill-gaps"=>{:type=>:boolean}, "microexon-search"=>{:type=>:boolean}, "butterfly-search"=>{:type=>:boolean}, "no-butterfly-search"=>{:type=>:boolean}, "keep-tmp"=>{:type=>:boolean}, "tmp-dir"=>{:type=>:string}, "segment-mismatches"=>{:type=>:numeric}, "segment-length"=>{:type=>:numeric}, "min-closure-exon"=>{:type=>:numeric}, "min-closure-intron"=>{:type=>:numeric}, "max-closure-intron"=>{:type=>:numeric}, "min-coverage-intron"=>{:type=>:numeric}, "max-coverage-intron"=>{:type=>:numeric}, "min-segment-intron"=>{:type=>:numeric}, "max-segment-intron"=>{:type=>:numeric}, "rg-id"=>{:type=>:string}, "rg-sample"=>{:type=>:string}, "rg-library"=>{:type=>:string}, "rg-description"=>{:type=>:string}, "rg-platform-unit"=>{:type=>:string}, "rg-center"=>{:type=>:string}, "rg-date"=>{:type=>:string}, "rg-platform"=>{:type=>:string}, :parameter_xxx=>{:type=>:numeric}}
    end
    
    it "set a default option to be returned as params" do
      tophat = Bio::Ngs::Tophat.new
      #setting a default options
      #TODO: add check between type and default value, in the main class,
      # Thor already does it.
      tophat.options={:parameter_xxx=>{:type=>:numeric, :default=>10}}
      tophat.params.should == {:parameter_xxx=>{:type=>:numeric, :default=>10}}
    end

    it "get normalized options" do
      tophat = Bio::Ngs::Tophat.new
      #setting a default options
      #TODO: add check between type and default value, in the main class,
      # Thor already does it.
      tophat.options={:parameter_xxx=>{:type=>:numeric, :default=>10}}
      tophat.normalize_params.should == "--parameter_xxx=10"
    end

    it "does not save a valid parameter/option" do
      tophat = Bio::Ngs::Tophat.new
      tophat.params={:fake_parameter=>1234567890}
      tophat.normalize_params.should == []
    end

    it "set a default option and get the parameters for the binary program" do
      tophat = Bio::Ngs::Tophat.new
      #setting a default options
      #TODO: add check between type and default value, in the main class,
      # Thor already does it.
      tophat.options={:parameter_xxx=>{:type=>:numeric, :default=>10}}
      tophat.params={:fake_parameter=>01}
      tophat.normalize_params.should == "--parameter_xxx=10"
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
