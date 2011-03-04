#
#   tophat.rb - description
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <@bioruby.org>
# License:: The Ruby License
#
#


#require 'bio/command'
#require 'shellwords'
#require 'thor'
#require 'bio/ngs/utils'

# TopHat maps short sequences from spliced transcripts to whole genomes.
# 
# Usage:
#     tophat [options] <bowtie_index> <reads1[,reads2,...,readsN]> [reads1[,reads2,...,readsN]] [quals1,[quals2,...,qualsN]] [quals1[,quals2,...,qualsN]]
#     
# Options:
#     -v/--version
#     -o/--output-dir                <string>    [ default: ./tophat_out ]
#     -a/--min-anchor                <int>       [ default: 8            ]
#     -m/--splice-mismatches         <0-2>       [ default: 0            ]
#     -i/--min-intron                <int>       [ default: 50           ]
#     -I/--max-intron                <int>       [ default: 500000       ]
#     -g/--max-multihits             <int>       [ default: 40           ]
#     -F/--min-isoform-fraction      <float>     [ default: 0.15         ]
#     --solexa-quals                          
#     --solexa1.3-quals                          (same as phred64-quals)
#     --phred64-quals                            (same as solexa1.3-quals)
#     -Q/--quals
#     --integer-quals
#     -C/--color                                 (Solid - color space)
#     --color-out
#     --library-type                             (--fr-unstranded, --fr-firststrand, --fr-secondstrand, --ff-unstranded, --ff-firststrand, --ff-secondstrand)
#     -p/--num-threads               <int>       [ default: 1            ]
#     -G/--GTF                       <filename>
#     -j/--raw-juncs                 <filename>
#     -r/--mate-inner-dist           <int>       
#     --mate-std-dev                 <int>       [ default: 20           ]
#     --no-novel-juncs                           
#     --no-gtf-juncs                             
#     --no-coverage-search
#     --coverage-search                                              
#     --no-closure-search
#     --closure-search
#     --fill-gaps        
#     --microexon-search
#     --butterfly-search
#     --no-butterfly-search
#     --keep-tmp
#     --tmp-dir                      <dirname>
#     
# Advanced Options:
# 
#     --segment-mismatches           <int>       [ default: 2            ]
#     --segment-length               <int>       [ default: 25           ]
#     --min-closure-exon             <int>       [ default: 100          ]
#     --min-closure-intron           <int>       [ default: 50           ]
#     --max-closure-intron           <int>       [ default: 5000         ]
#     --min-coverage-intron          <int>       [ default: 50           ]
#     --max-coverage-intron          <int>       [ default: 20000        ]
#     --min-segment-intron           <int>       [ default: 50           ]
#     --max-segment-intron           <int>       [ default: 500000       ] 
# 
# SAM Header Options (for embedding sequencing run metadata in output):
#     --rg-id                        <string>    (read group ID)
#     --rg-sample                    <string>    (sample ID)
#     --rg-library                   <string>    (library ID)
#     --rg-description               <string>    (descriptive string, no tabs allowed)
#     --rg-platform-unit             <string>    (e.g Illumina lane ID)
#     --rg-center                    <string>    (sequencing center name)
#     --rg-date                      <string>    (ISO 8601 date of the sequencing run)
#     --rg-platform                  <string>    (Sequencing platform descriptor)  
# 
#     for detailed help see http://tophat.cbcb.umd.edu/manual.html


module Bio
  module Ngs    
    class Tophat

      include Bio::Command::Wrapper

      set_program Bio::Ngs::Utils.os_binary("tophat/tophat")
      # User should provide a complete path to the tool.
      # I think it would it better identify the program from just a name
      # looking int othe ext/ or host system path
      # Why not grab the file name from the class name if not specified ?

      add_option "output-dir",:type => :string, :aliases => '-o'
      add_option "min-anchor", :type => :numeric, :aliases => '-a'
      add_option "splice-mismatches", :type => :numeric, :aliases => '-m'
      add_option "min-intron", :type => :numeric , :aliases => '-i'
      add_option "max-intront", :type => :numeric, :aliases => '-I'
      add_option "max-multihits", :type => :numeric, :aliases => '-g'
      add_option "min-isoform_fraction", :type => :numeric, :aliases => '-F'
      add_option "solexa-quals", :type => :boolean
      add_option "solexa1.3-quals", :type => :boolean, :aliases => '--phred64-quals'
      add_option :quals, :type => :boolean, :aliases => '-Q'
      add_option "integer-quals", :type => :boolean
      add_option :color, :type => :boolean, :aliases => '-C'
      add_option "library-type", :type => :string
      add_option "num-threads", :type => :numeric, :aliases => '-p'
      add_option "GTF", :type => :string, :aliases => '-G'
      add_option "raw-juncs", :type => :string, :aliases => '-j'
      add_option :insertions, :type => :string
      add_option :deletions, :type => :string
      add_option "mate-inner-dist", :type=>:numeric, :aliases => '-r'
      add_option "mate-std-dev", :type => :numeric
      add_option "no-novel-juncs", :type => :boolean
      add_option "no-gtf-juncs", :type => :boolean
      add_option "no-coverage-search", :type => :boolean
      add_option "coverage-search", :type => :boolean
      add_option "no-closure-search", :type => :boolean
      add_option "closure-search", :type => :boolean
      add_option "fill-gaps", :type => :boolean
      add_option "microexon-search", :type => :boolean
      add_option "butterfly-search", :type => :boolean
      add_option "no-butterfly-search", :type => :boolean
      add_option "keep-tmp", :type => :boolean
      add_option "tmp-dir", :type => :string
      add_option "segment-mismatches", :type => :numeric
      add_option "segment-length", :type => :numeric
      add_option "min-closure-exon", :type => :numeric
      add_option "min-closure-intron", :type => :numeric
      add_option "max-closure-intron", :type => :numeric
      add_option "min-coverage-intron", :type => :numeric
      add_option "max-coverage-intron", :type => :numeric
      add_option "min-segment-intron", :type => :numeric
      add_option "max-segment-intron", :type => :numeric
      add_option "rg-id", :type => :string
      add_option "rg-sample", :type => :string
      add_option "rg-library", :type => :string
      add_option "rg-description", :type => :string
      add_option "rg-platform-unit", :type => :string
      add_option "rg-center", :type => :string
      add_option "rg-date", :type => :string
      add_option "rg-platform", :type => :string

    end #That
  end #Ngs
end #Bio 





# module Bio
#   module Ngs
#     class Tophat < Thor
#       #include Wrapper
# 
#       desc "main", 'tophat for alignment'     

#       def main
#         options = normalize_options
#         #puts options
#         @output = Bio::Command.query_command [program, options]        
#       end
# 
#       def initialize(options="--help")
#         super
#         @program = Bio::Ngs::Utils.os_binary("tophat/tophat")
#       end
# 
#       no_tasks do
#         def program
#           @program
#         end
#       end
# 
#       private
#       def normalize_options
#         @options = options.to_a if options.kind_of? Hash
#         if options.kind_of? Array
#           @options = options.map{|opt| "--#{opt[0].gsub(/--/,"")}=#{opt[1]}"}.join(" ")
#         end
#         @options
#       end#normalize_options
# 
#     end #Tophat
#   end #Ngs
# end #Bio