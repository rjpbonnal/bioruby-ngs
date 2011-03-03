require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'thor/base'
#require 'bio/appl/ngs/tophat'

describe "Tophat" do 
  describe "class" do
    it "default options" do
      Bio::Ngs::Tophat.options.should == {:reads=>{:type=>:array, :required=>true}, :quality=>{:type=>:array, :required=>true}, "output-dir"=>{:type=>:string, :aliases=>"-o"}, "min-anchor"=>{:type=>:numeric, :aliases=>"-a"}, "splice-mismatches"=>{:type=>:numeric, :aliases=>"-m"}, "min-intron"=>{:type=>:numeric, :aliases=>"-i"}, "max-intront"=>{:type=>:numeric, :aliases=>"-I"}, "max-multihits"=>{:type=>:numeric, :aliases=>"-g"}, "min-isoform_fraction"=>{:type=>:numeric, :aliases=>"-F"}, "solexa-quals"=>{:type=>:boolean}, "solexa1.3-quals"=>{:type=>:boolean, :aliases=>"--phred64-quals"}, :quals=>{:type=>:boolean, :aliases=>"-Q"}, "integer-quals"=>{:type=>:boolean}, :color=>{:type=>:boolean, :aliases=>"-C"}, "library-type"=>{:type=>:string}, "num-threads"=>{:type=>:numeric, :aliases=>"-p"}, "GTF"=>{:type=>:string, :aliases=>"-G"}, "raw-juncs"=>{:type=>:string, :aliases=>"-j"}, :insertions=>{:type=>:string}, :deletions=>{:type=>:string}, "mate-inner-dist"=>{:type=>:numeric, :aliases=>"-r"}, "mate-std-dev"=>{:type=>:numeric}, "no-novel-juncs"=>{:type=>:boolean}, "no-gtf-juncs"=>{:type=>:boolean}, "no-coverage-search"=>{:type=>:boolean}, "coverage-search"=>{:type=>:boolean}, "no-closure-search"=>{:type=>:boolean}, "closure-search"=>{:type=>:boolean}, "fill-gaps"=>{:type=>:boolean}, "microexon-search"=>{:type=>:boolean}, "butterfly-search"=>{:type=>:boolean}, "no-butterfly-search"=>{:type=>:boolean}, "keep-tmp"=>{:type=>:boolean}, "tmp-dir"=>{:type=>:string}, "segment-mismatches"=>{:type=>:numeric}, "segment-length"=>{:type=>:numeric}, "min-closure-exon"=>{:type=>:numeric}, "min-closure-intron"=>{:type=>:numeric}, "max-closure-intron"=>{:type=>:numeric}, "min-coverage-intron"=>{:type=>:numeric}, "max-coverage-intron"=>{:type=>:numeric}, "min-segment-intron"=>{:type=>:numeric}, "max-segment-intron"=>{:type=>:numeric}, "rg-id"=>{:type=>:string}, "rg-sample"=>{:type=>:string}, "rg-library"=>{:type=>:string}, "rg-description"=>{:type=>:string}, "rg-platform-unit"=>{:type=>:string}, "rg-center"=>{:type=>:string}, "rg-date"=>{:type=>:string}, "rg-platform"=>{:type=>:string}}     
    end
    
    it "default program name" do
      Bio::Ngs::Tophat.program.should == Bio::NGS::Utils.os_binary("tophat/tophat")
    end
  end
  
  describe "instance" do
    it "default options" do
      Bio::Ngs::Tophat.new.options.should == {:reads=>{:type=>:array, :required=>true}, :quality=>{:type=>:array, :required=>true}, "output-dir"=>{:type=>:string, :aliases=>"-o"}, "min-anchor"=>{:type=>:numeric, :aliases=>"-a"}, "splice-mismatches"=>{:type=>:numeric, :aliases=>"-m"}, "min-intron"=>{:type=>:numeric, :aliases=>"-i"}, "max-intront"=>{:type=>:numeric, :aliases=>"-I"}, "max-multihits"=>{:type=>:numeric, :aliases=>"-g"}, "min-isoform_fraction"=>{:type=>:numeric, :aliases=>"-F"}, "solexa-quals"=>{:type=>:boolean}, "solexa1.3-quals"=>{:type=>:boolean, :aliases=>"--phred64-quals"}, :quals=>{:type=>:boolean, :aliases=>"-Q"}, "integer-quals"=>{:type=>:boolean}, :color=>{:type=>:boolean, :aliases=>"-C"}, "library-type"=>{:type=>:string}, "num-threads"=>{:type=>:numeric, :aliases=>"-p"}, "GTF"=>{:type=>:string, :aliases=>"-G"}, "raw-juncs"=>{:type=>:string, :aliases=>"-j"}, :insertions=>{:type=>:string}, :deletions=>{:type=>:string}, "mate-inner-dist"=>{:type=>:numeric, :aliases=>"-r"}, "mate-std-dev"=>{:type=>:numeric}, "no-novel-juncs"=>{:type=>:boolean}, "no-gtf-juncs"=>{:type=>:boolean}, "no-coverage-search"=>{:type=>:boolean}, "coverage-search"=>{:type=>:boolean}, "no-closure-search"=>{:type=>:boolean}, "closure-search"=>{:type=>:boolean}, "fill-gaps"=>{:type=>:boolean}, "microexon-search"=>{:type=>:boolean}, "butterfly-search"=>{:type=>:boolean}, "no-butterfly-search"=>{:type=>:boolean}, "keep-tmp"=>{:type=>:boolean}, "tmp-dir"=>{:type=>:string}, "segment-mismatches"=>{:type=>:numeric}, "segment-length"=>{:type=>:numeric}, "min-closure-exon"=>{:type=>:numeric}, "min-closure-intron"=>{:type=>:numeric}, "max-closure-intron"=>{:type=>:numeric}, "min-coverage-intron"=>{:type=>:numeric}, "max-coverage-intron"=>{:type=>:numeric}, "min-segment-intron"=>{:type=>:numeric}, "max-segment-intron"=>{:type=>:numeric}, "rg-id"=>{:type=>:string}, "rg-sample"=>{:type=>:string}, "rg-library"=>{:type=>:string}, "rg-description"=>{:type=>:string}, "rg-platform-unit"=>{:type=>:string}, "rg-center"=>{:type=>:string}, "rg-date"=>{:type=>:string}, "rg-platform"=>{:type=>:string}}
    end
    
    it "default program name" do
      Bio::Ngs::Tophat.new("/usr/local/bin/tophat").program.should == "/usr/local/bin/tophat"
    end
    
    it "overwrite specifc options" do
      tophat = Bio::Ngs::Tophat.new
      tophat.options={:reads=>{:type=>:numeric}}
      tophat.options[:reads][:type].should == :numeric
    end
  
    it "add specifc options" do
      tophat = Bio::Ngs::Tophat.new
      tophat.options={:parameter_xxx=>{:type=>:numeric}}
      tophat.options.should == {:reads=>{:type=>:array, :required=>true}, :quality=>{:type=>:array, :required=>true}, "output-dir"=>{:type=>:string, :aliases=>"-o"}, "min-anchor"=>{:type=>:numeric, :aliases=>"-a"}, "splice-mismatches"=>{:type=>:numeric, :aliases=>"-m"}, "min-intron"=>{:type=>:numeric, :aliases=>"-i"}, "max-intront"=>{:type=>:numeric, :aliases=>"-I"}, "max-multihits"=>{:type=>:numeric, :aliases=>"-g"}, "min-isoform_fraction"=>{:type=>:numeric, :aliases=>"-F"}, "solexa-quals"=>{:type=>:boolean}, "solexa1.3-quals"=>{:type=>:boolean, :aliases=>"--phred64-quals"}, :quals=>{:type=>:boolean, :aliases=>"-Q"}, "integer-quals"=>{:type=>:boolean}, :color=>{:type=>:boolean, :aliases=>"-C"}, "library-type"=>{:type=>:string}, "num-threads"=>{:type=>:numeric, :aliases=>"-p"}, "GTF"=>{:type=>:string, :aliases=>"-G"}, "raw-juncs"=>{:type=>:string, :aliases=>"-j"}, :insertions=>{:type=>:string}, :deletions=>{:type=>:string}, "mate-inner-dist"=>{:type=>:numeric, :aliases=>"-r"}, "mate-std-dev"=>{:type=>:numeric}, "no-novel-juncs"=>{:type=>:boolean}, "no-gtf-juncs"=>{:type=>:boolean}, "no-coverage-search"=>{:type=>:boolean}, "coverage-search"=>{:type=>:boolean}, "no-closure-search"=>{:type=>:boolean}, "closure-search"=>{:type=>:boolean}, "fill-gaps"=>{:type=>:boolean}, "microexon-search"=>{:type=>:boolean}, "butterfly-search"=>{:type=>:boolean}, "no-butterfly-search"=>{:type=>:boolean}, "keep-tmp"=>{:type=>:boolean}, "tmp-dir"=>{:type=>:string}, "segment-mismatches"=>{:type=>:numeric}, "segment-length"=>{:type=>:numeric}, "min-closure-exon"=>{:type=>:numeric}, "min-closure-intron"=>{:type=>:numeric}, "max-closure-intron"=>{:type=>:numeric}, "min-coverage-intron"=>{:type=>:numeric}, "max-coverage-intron"=>{:type=>:numeric}, "min-segment-intron"=>{:type=>:numeric}, "max-segment-intron"=>{:type=>:numeric}, "rg-id"=>{:type=>:string}, "rg-sample"=>{:type=>:string}, "rg-library"=>{:type=>:string}, "rg-description"=>{:type=>:string}, "rg-platform-unit"=>{:type=>:string}, "rg-center"=>{:type=>:string}, "rg-date"=>{:type=>:string}, "rg-platform"=>{:type=>:string}, :parameter_xxx=>{:type=>:numeric}}
    end
    
    it "expose to thor class default" do
      Bio::Ngs::Tophat.new.dynamic_task({}).should == Thor::DynamicTask.new("")
    end
  end #instance
end


# describe Tophat do
#   describe "Tophat" do
#     it "the program is " do
#       Bio::Ngs::Tophat.new.program.should == Bio::NGS::Utils.os_binary("tophat/tophat")
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
