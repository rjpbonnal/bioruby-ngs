require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'thor/base'

describe "SffExtract" do
  
  describe "class" do
    it "should have default options" do
      Bio::Ngs::SffExtract.options.should == {"append" => {:type => :boolean, :aliases => "-a", :desc =>"append output to existing files"},
                                              "xml_info" => {:type => :string, :aliases => "-i", :desc => "extra info to write in the xml file"},
                                              "linker_file" => {:type => :string, :aliases => "-l", :desc => "FASTA file with paired-end linker sequences"},
                                              "clip" => {:type => :boolean, :aliases => "-c", :desc => "clip (completely remove) ends with low qual and/or adaptor sequence"},
                                              "upper_case" => {:type => :boolean, :aliases => "-u", :desc => "all bases in upper case, including clipped ends"},
                                              "min_left_clip" => {:type => :numeric, :desc => "if the left clip coming from the SFF is smaller than this value, override it"},
                                              "fastq" => {:type => :boolean, :aliases => "-Q", :desc => "store as FASTQ file instead of FASTA + FASTA quality file"},
                                              "out_basename" => {:type => :string, :aliases => "-o", :desc => "base name for all output files"},
                                              "seq_file" => {:type => :string, :aliases => "-s", :desc => "output sequence file name"},
                                              "qual_file" => {:type => :string, :aliases => "-q", :desc => "output quality file name"},
                                              "xml_file" => {:type => :string, :aliases => "-x", :desc => "output ancillary xml file name"}
                                              }
    end
    it "should have a default program name" do
      Bio::Ngs::SffExtract.program.should == Bio::Ngs::Utils.binary("sff_extract")
    end
    
  end
  
  describe "instance" do
    it "has default options" do
      Bio::Ngs::SffExtract.new.options.should == {"append" => {:type => :boolean, :aliases => "-a", :desc =>"append output to existing files"},
                                              "xml_info" => {:type => :string, :aliases => "-i", :desc => "extra info to write in the xml file"},
                                              "linker_file" => {:type => :string, :aliases => "-l", :desc => "FASTA file with paired-end linker sequences"},
                                              "clip" => {:type => :boolean, :aliases => "-c", :desc => "clip (completely remove) ends with low qual and/or adaptor sequence"},
                                              "upper_case" => {:type => :boolean, :aliases => "-u", :desc => "all bases in upper case, including clipped ends"},
                                              "min_left_clip" => {:type => :numeric, :desc => "if the left clip coming from the SFF is smaller than this value, override it"},
                                              "fastq" => {:type => :boolean, :aliases => "-Q", :desc => "store as FASTQ file instead of FASTA + FASTA quality file"},
                                              "out_basename" => {:type => :string, :aliases => "-o", :desc => "base name for all output files"},
                                              "seq_file" => {:type => :string, :aliases => "-s", :desc => "output sequence file name"},
                                              "qual_file" => {:type => :string, :aliases => "-q", :desc => "output quality file name"},
                                              "xml_file" => {:type => :string, :aliases => "-x", :desc => "output ancillary xml file name"}
                                              }
    end
    
    it "has custom name" do
      Bio::Ngs::SffExtract.new("/usr/local/bin/sff_extract").program.should == "/usr/local/bin/sff_extract"
    end
    
    it "overwrites specifc option" do
      tophat = Bio::Ngs::SffExtract.new
      tophat.options={:reads=>{:type=>:numeric}}
      tophat.options[:reads][:type].should == :numeric
    end
  
    it "add custom option" do
      tophat = Bio::Ngs::SffExtract.new
      tophat.options={:parameter_xxx=>{:type=>:numeric}}
      tophat.options.should == {"append" => {:type => :boolean, :aliases => "-a", :desc =>"append output to existing files"},
                                              "xml_info" => {:type => :string, :aliases => "-i", :desc => "extra info to write in the xml file"},
                                              "linker_file" => {:type => :string, :aliases => "-l", :desc => "FASTA file with paired-end linker sequences"},
                                              "clip" => {:type => :boolean, :aliases => "-c", :desc => "clip (completely remove) ends with low qual and/or adaptor sequence"},
                                              "upper_case" => {:type => :boolean, :aliases => "-u", :desc => "all bases in upper case, including clipped ends"},
                                              "min_left_clip" => {:type => :numeric, :desc => "if the left clip coming from the SFF is smaller than this value, override it"},
                                              "fastq" => {:type => :boolean, :aliases => "-Q", :desc => "store as FASTQ file instead of FASTA + FASTA quality file"},
                                              "out_basename" => {:type => :string, :aliases => "-o", :desc => "base name for all output files"},
                                              "seq_file" => {:type => :string, :aliases => "-s", :desc => "output sequence file name"},
                                              "qual_file" => {:type => :string, :aliases => "-q", :desc => "output quality file name"},
                                              "xml_file" => {:type => :string, :aliases => "-x", :desc => "output ancillary xml file name"},
                                              :parameter_xxx=>{:type=>:numeric}
                                              }
    end
    
    it "set a default option to be returned as params" do
      tophat = Bio::Ngs::SffExtract.new
      tophat.options={:parameter_xxx=>{:type=>:numeric, :default=>10}}
      tophat.params.should == {:parameter_xxx=>{:type=>:numeric, :default=>10}}
    end

    it "get normalized options" do
      tophat = Bio::Ngs::SffExtract.new
      tophat.options={:parameter_xxx=>{:type=>:numeric, :default=>10}}
      tophat.normalize_params.should == "--parameter_xxx=10"
    end

    it "does not save a valid parameter/option" do
      tophat = Bio::Ngs::SffExtract.new
      tophat.params={:fake_parameter=>1234567890}
      tophat.normalize_params.should == []
    end

    it "set a default option and get the parameters for the binary program" do
      tophat = Bio::Ngs::SffExtract.new
      tophat.options={:parameter_xxx=>{:type=>:numeric, :default=>10}}
      tophat.params={:fake_parameter=>01}
      tophat.normalize_params.should == "--parameter_xxx=10"
    end
    
  end
  
end