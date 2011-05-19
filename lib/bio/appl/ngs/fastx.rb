#
#   fastx.rb - The FASTX-Toolkit is a collection of command line tools for Short-Reads FASTA/FASTQ files preprocessing.
# 
# Next-Generation sequencing machines usually produce FASTA or FASTQ files, containing multiple short-reads sequences (possibly with quality information).
# 
# The main processing of such FASTA/FASTQ files is mapping (aka aligning) the sequences to reference genomes or other databases using specialized programs. Example of such mapping programs are: Blat, SHRiMP, LastZ, MAQ and many many others.
# 
# However,
# It is sometimes more productive to preprocess the FASTA/FASTQ files before mapping the sequences to the genome - manipulating the sequences to produce better mapping results.
# 
# The FASTX-Toolkit tools perform some of these preprocessing tasks.
# http://hannonlab.cshl.edu/fastx_toolkit/
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>
# License:: The Ruby License
#
# + Mapped
# - Not Yet Mapped
# 
# - fastx_artifacts_filter
# - fastx_collapser
# + fastx_quality_stats
# - fastx_trimmer
# - fastx_barcode_splitter.pl
# - fastx_nucleotide_distribution_graph.sh
# - fastx_renamer
# - fastx_uncollapser
# - fastx_clipper
# - fastx_nucleotide_distribution_line_graph.sh
# - fastx_reverse_complement
# + fastq_coverage_graph.sh
# - fastq_masker
# + fastq_quality_boxplot_graph.sh
# - fastq_quality_converter
# - fastq_quality_filter
# - fastq_quality_trimmer
# - fastq_to_fasta



module Bio
  module Ngs    
    module Fastx

      # [-h]         = This helpful help screen.
      # [-t N]       = Quality threshold - nucleotides with lower 
      #                quality will be trimmed (from the end of the sequence).
      # [-l N]       = Minimum length - sequences shorter than this (after trimming)
      #                will be discarded. Default = 0 = no minimum length. 
      # [-z]         = Compress output with GZIP.
      # [-i INFILE]  = FASTQ input file. default is STDIN.
      # [-o OUTFILE] = FASTQ output file. default is STDOUT.
      # [-v]         = Verbose - report number of sequences.
      #                If [-o] is specified,  report will be printed to STDOUT.
      #                If [-o] is not specified (and output goes to STDOUT),
      #                report will be printed to STDERR.
      class Trim
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("fastq_quality_trimmer")
        use_aliases
        add_option :min_size, :type=>:numeric, :default=>20, :aliases => "-l", :desc=>"Minimum length - sequences shorter than this (after trimming)
        will be discarded. Default = 0 = no minimum length."
        add_option :min_quality, :type=>:numeric, :default=>10, :aliases => "-t", :desc=>"Quality threshold - nucleotides with lower 
        quality will be trimmed (from the end of the sequence)."
        add_option :output, :type=>:string, :aliases => "-o", :desc => "FASTQ output file."
        add_option :input, :type=>:string, :aliases => "-i", :desc => "FASTQ input file."
        add_option :gzip, :type => :boolean, :aliases => "-z", :desc => "Compress output with GZIP."
        add_option :verbose, :type => :boolean, :alises => "-v", :desc => "[-v]         = Verbose - report number of sequences.
        If [-o] is specified,  report will be printed to STDOUT.
        If [-o] is not specified (and output goes to STDOUT),
        report will be printed to STDERR."
      end #Trim

      # Solexa-Quality BoxPlot plotter
      # Generates a solexa quality score box-plot graph 
      # 
      # Usage: /usr/local/bin/fastq_quality_boxplot_graph.sh [-i INPUT.TXT] [-t TITLE] [-p] [-o OUTPUT]
      # 
      #   [-p]           - Generate PostScript (.PS) file. Default is PNG image.
      #   [-i INPUT.TXT] - Input file. Should be the output of "solexa_quality_statistics" program.
      #   [-o OUTPUT]    - Output file name. default is STDOUT.
      #   [-t TITLE]     - Title (usually the solexa file name) - will be plotted on the graph.      
      class ReadsBoxPlot
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("fastq_quality_boxplot_graph.sh")
        use_aliases
        add_option :ps, :type => :boolean, :aliases => "-p", :desc => "Generate PostScript (.PS) file. Default is PNG image."
        add_option :output, :type=>:string, :aliases => "-o", :desc => "FASTQ output file."
        add_option :input, :type=>:string, :aliases => "-i", :desc => "FASTQ input file."
        add_option :title, :type => :string, :aliases => "-t", :desc => "Title (usually the solexa file name) - will be plotted on the graph."
      end #ReadsBoxPlot

      # Solexa-Reads coverage plotter
      # Generates a solexa line coverage graph 
      # 
      # Usage: /usr/local/bin/fastq_coverage_graph.sh [-i INPUT.TXT] [-t TITLE] [-p] [-o OUTPUT]
      # 
      #   [-p]           - Generate PostScript (.PS) file. Default is PNG image.
      #   [-i INPUT.TXT] - Input file. Should be the output of "solexa_quality_statistics" program.
      #   [-o OUTPUT]    - Output file name. default is STDOUT.
      #   [-t TITLE]     - Title (usually the solexa file name) - will be plotted on the graph.      
      class ReadsCoverage
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("fastq_coverage_graph.sh")
        use_aliases
        add_option :ps, :type => :boolean, :aliases => "-p", :desc => "Generate PostScript (.PS) file. Default is PNG image."
        add_option :output, :type=>:string, :aliases => "-o", :desc => "FASTQ output file."
        add_option :input, :type=>:string, :aliases => "-i", :desc => "FASTQ input file."
        add_option :title, :type => :string, :aliases => "-t", :desc => "Title (usually the solexa file name) - will be plotted on the graph."
      end #ReadsCoverage


      # usage: fastx_quality_stats [-h] [-N] [-i INFILE] [-o OUTFILE]
      # Part of FASTX Toolkit 0.0.13 by A. Gordon (gordon@cshl.edu)
      # 
      #    [-h] = This helpful help screen.
      #    [-i INFILE]  = FASTQ input file. default is STDIN.
      #    [-o OUTFILE] = TEXT output file. default is STDOUT.
      #    [-N]         = New output format (with more information per nucleotide/cycle).
      # 
      # The *OLD* output TEXT file will have the following fields (one row per column):
      #   column  = column number (1 to 36 for a 36-cycles read solexa file)
      #   count   = number of bases found in this column.
      #   min     = Lowest quality score value found in this column.
      #   max     = Highest quality score value found in this column.
      #   sum     = Sum of quality score values for this column.
      #   mean    = Mean quality score value for this column.
      #   Q1  = 1st quartile quality score.
      #   med = Median quality score.
      #   Q3  = 3rd quartile quality score.
      #   IQR = Inter-Quartile range (Q3-Q1).
      #   lW  = 'Left-Whisker' value (for boxplotting).
      #   rW  = 'Right-Whisker' value (for boxplotting).
      #   A_Count = Count of 'A' nucleotides found in this column.
      #   C_Count = Count of 'C' nucleotides found in this column.
      #   G_Count = Count of 'G' nucleotides found in this column.
      #   T_Count = Count of 'T' nucleotides found in this column.
      #   N_Count = Count of 'N' nucleotides found in this column.
      #   max-count = max. number of bases (in all cycles)
      # 
      # 
      # The *NEW* output format:
      #   cycle (previously called 'column') = cycle number
      #   max-count
      #   For each nucleotide in the cycle (ALL/A/C/G/T/N):
      #     count   = number of bases found in this column.
      #     min     = Lowest quality score value found in this column.
      #     max     = Highest quality score value found in this column.
      #     sum     = Sum of quality score values for this column.
      #     mean    = Mean quality score value for this column.
      #     Q1  = 1st quartile quality score.
      #     med = Median quality score.
      #     Q3  = 3rd quartile quality score.
      #     IQR = Inter-Quartile range (Q3-Q1).
      #     lW  = 'Left-Whisker' value (for boxplotting).
      #     rW  = 'Right-Whisker' value (for boxplotting).
      class FastqStats
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("fastx_quality_stats")
        use_aliases
        add_option :output, :type=>:string, :aliases => "-o", :desc => "FASTQ output file."
        add_option :input, :type=>:string, :aliases => "-i", :desc => "FASTQ input file."
        add_option :new_format, :type => :boolean, :aliases => "-N", :desc => "New output format (with more information per nucleotide/cycle)."
      end #ReadsCoverage      

    end #Fastx
  end #Ngs
end #Bio