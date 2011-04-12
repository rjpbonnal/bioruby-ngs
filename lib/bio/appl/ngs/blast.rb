module Bio
  module Ngs
    class Blast
      
      include Bio::Command::Wrapper
      
      class BlastN < Blast
        set_program Bio::Ngs::Utils.binary("blastn")
        add_option "evalue", :type => :string, :desc => "E-value cutoff"
        add_option "query", :type => :string, :desc => "Query sequence"
        add_option "db", :type => :string, :desc => "Database sequences"
        add_option "query", :type => :string, :desc => "Query sequence"
        add_option "word_size", :type => :string, :desc => "Query sequence"
        add_option "task", :type => :string, :desc => "Task type", :default => "blastn"
        add_option "out", :type => :string, :desc => "Output file", :default => "blastout.xml"
        add_option "outfmt", :type => :numeric, :desc => "Output format type", :default => 5
        add_option "num_descriptions", :type => :numeric, :desc => "Number of HIT descriptions", :default => 1
        add_option "num_alignments", :type => :numeric, :desc => "Number of HIT alignments", :default => 1
        add_option "num_threads", :type => :numeric, :desc => "Number of threads", :default => 1
      end
      
      class BlastX < Blast
        set_program Bio::Ngs::Utils.binary("blastx")
        add_option "evalue", :type => :string, :desc => "E-value cutoff"
        add_option "query", :type => :string, :desc => "Query sequence"
        add_option "db", :type => :string, :desc => "Database sequences"
        add_option "query", :type => :string, :desc => "Query sequence"
        add_option "out", :type => :string, :desc => "Output file", :default => "blastout.xml"
        add_option "outfmt", :type => :numeric, :desc => "Output format type", :default => 5
        add_option "num_descriptions", :type => :numeric, :desc => "Number of HIT descriptions", :default => 1
        add_option "num_alignments", :type => :numeric, :desc => "Number of HIT alignments", :default => 1
        add_option "num_threads", :type => :numeric, :desc => "Number of threads", :default => 1
      end
    end
  end
end