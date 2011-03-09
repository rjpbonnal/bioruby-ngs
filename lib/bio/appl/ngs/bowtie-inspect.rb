#
#  bowtie-inspect.rb - Wrapper for bowtie-inspect
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#


# Usage: bowtie-inspect [options]* <ebwt_base>
#   <ebwt_base>        ebwt filename minus trailing .1.ebwt/.2.ebwt
# 
#   By default, prints FASTA records of the indexed nucleotide sequences to
#   standard out.  With -n, just prints names.  With -s, just prints a summary of
#   the index parameters and sequences.  With -e, preserves colors if applicable.
# 
# Options:
#   -a/--across <int>  Number of characters across in FASTA output (default: 60)
#   -n/--names         Print reference sequence names only
#   -s/--summary       Print summary incl. ref names, lengths, index properties
#   -e/--ebwt-ref      Reconstruct reference from ebwt (slow, preserves colors)
#   -v/--verbose       Verbose output (for debugging)
#   -h/--help          print detailed description of tool and its options
#   --help             print this usage message


module Bio
  module Ngs    
    class BowtieInspect

      include Bio::Command::Wrapper

      set_program Bio::Ngs::Utils.os_binary("bowtie/bowtie-inspect")
      # User should provide a complete path to the tool.
      # I think it would it better identify the program from just a name
      # looking int othe ext/ or host system path
      # Why not grab the file name from the class name if not specified ?

      set_output :stdout

      
      add_option "across",:type => :numeric, :aliases => '-a'
      add_option "names", :type => :boolean, :aliases => '-n'
      add_option "summary", :type => :boolean, :aliases => '-s'
      add_option "ebwt-ref", :type => :boolean, :aliases => '-e'
      add_option "verbose", :type => :boolean, :aliases => '-v'      
    end #BowtieInspect
  end#Ngs
end#Bio