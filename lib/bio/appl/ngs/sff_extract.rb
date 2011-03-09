module Bio
  module Ngs    
    class SffExtract

      include Bio::Command::Wrapper
      
      set_program Bio::Ngs::Utils.binary("sff_extract")
      add_option "append", :type => :boolean, :aliases => "-a", :desc => "append output to existing files"
      add_option "xml_info", :type => :string, :aliases => "-i", :desc => "extra info to write in the xml file" 
      add_option "linker_file", :type => :string, :aliases => "-l", :desc => "FASTA file with paired-end linker sequences"
      add_option "clip", :type => :boolean, :aliases => "-c", :desc => "clip (completely remove) ends with low qual and/or adaptor sequence"
      add_option "upper_case", :type => :boolean, :aliases => "-u", :desc => "all bases in upper case, including clipped ends"
      add_option "min_left_clip", :type => :numeric, :desc => "if the left clip coming from the SFF is smaller than this value, override it"
      add_option "fastq", :type => :boolean, :aliases => "-Q", :desc => "store as FASTQ file instead of FASTA + FASTA quality file"
      add_option "out_basename", :type => :string, :aliases => "-o", :desc => "base name for all output files"
      add_option "seq_file", :type => :string, :aliases => "-s", :desc => "output sequence file name"
      add_option "qual_file", :type => :string, :aliases => "-q", :desc => "output quality file name"
      add_option "xml_file", :type => :string, :aliases => "-x", :desc => "output ancillary xml file name"
      
      
    end
  end
end