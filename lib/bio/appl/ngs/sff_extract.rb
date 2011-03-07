module Bio
  module Ngs    
    class Tophat

      include Bio::Command::Wrapper
      
      set_program Bio::Ngs::Utils.binary("sff_extract")
      add_option "append", :type => :boolean, :aliases => "-a"
      add_option "xml_info", :type => :string, :aliases => "-i"
      add_option "linker_file", :type => :string, :aliases => "-l"
      add_option "clip", :type => :boolean, :aliases => "-c"
      add_option "upper_case", :type => :boolean, :aliases => "-u"
      add_option "min_left_clip", :type => :integer
      add_option "fastq", :type => :boolean, :aliases => "-Q"
      add_option "out_basename", :type => :string, :aliases => "-o"
      add_option "seq_file", :type => :string, :aliases => "-s"
      add_option "qual_file", :type => :string, :aliases => "-q"
      add_option "xml_file", :type => :string, :aliases => "-x"
      
      
    end
  end
end