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
#     tophat [options] <bowtie_index> <reads1[,reads2,...]> [reads1[,reads2,...]] \
#                                     [quals1,[quals2,...]] [quals1[,quals2,...]]
# 
# Options:
#     -v/--version
#     -o/--output-dir                <string>    [ default: ./tophat_out     ]
#     -a/--min-anchor                <int>       [ default: 8                ]
#     -m/--splice-mismatches         <0-2>       [ default: 0                ]
#     -i/--min-intron-length         <int>       [ default: 50               ]
#     -I/--max-intron-length         <int>       [ default: 500000           ]
#     -g/--max-multihits             <int>       [ default: 20               ]
#     -F/--min-isoform-fraction      <float>     [ default: 0.15             ]
#     --max-insertion-length         <int>       [ default: 3                ]
#     --max-deletion-length          <int>       [ default: 3                ]
#     --solexa-quals
#     --solexa1.3-quals                          (same as phred64-quals)
#     --phred64-quals                            (same as solexa1.3-quals)
#     -Q/--quals
#     --integer-quals
#     -C/--color                                 (Solid - color space)
#     --color-out
#     --library-type                 <string>    (fr-unstranded, fr-firststrand,
#                                                 fr-secondstrand)
#     -p/--num-threads               <int>       [ default: 1                ]
#     -G/--GTF                       <filename>
#     -j/--raw-juncs                 <filename>
#     --insertions                   <filename>
#     --deletions                    <filename>
#     -r/--mate-inner-dist           <int>
#     --mate-std-dev                 <int>       [ default: 20               ]
#     --no-novel-juncs
#     --no-novel-indels
#     --no-gtf-juncs
#     --no-coverage-search
#     --coverage-search
#     --no-closure-search
#     --closure-search
#     --microexon-search
#     --butterfly-search
#     --no-butterfly-search
#     --keep-tmp
#     --tmp-dir                      <dirname>   [ default: <output_dir>/tmp ]
#     -z/--zpacker                   <program>   [ default: gzip             ]
#     -X/--unmapped-fifo                         [ use mkfifo to compress more temporary files]
# 
# Advanced Options:
#     --initial-read-mismatches      <int>       [ default: 2                ]
#     --segment-mismatches           <int>       [ default: 2                ]
#     --segment-length               <int>       [ default: 25               ]
#     --bowtie-n                                 [ default: bowtie -v        ]
#     --min-closure-exon             <int>       [ default: 100              ]
#     --min-closure-intron           <int>       [ default: 50               ]
#     --max-closure-intron           <int>       [ default: 5000             ]
#     --min-coverage-intron          <int>       [ default: 50               ]
#     --max-coverage-intron          <int>       [ default: 20000            ]
#     --min-segment-intron           <int>       [ default: 50               ]
#     --max-segment-intron           <int>       [ default: 500000           ]
#     --no-sort-bam                              [Output BAM is not coordinate-sorted]
#     --no-convert-bam                           [Do not convert to bam format.
#                                                 Output is <output_dir>accepted_hit.sam.
#                                                 Implies --no-sort-bam.]
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

      set_program Bio::Ngs::Utils.binary("tophat")

      add_option "output-dir",:type => :string, :aliases => '-o'
      add_option "min-anchor", :type => :numeric, :aliases => '-a'
      add_option "splice-mismatches", :type => :numeric, :aliases => '-m'
      add_option "min-intron-length", :type => :numeric , :aliases => '-i'
      add_option "max-intron-length", :type => :numeric, :aliases => '-I'
      add_option "max-multihits", :type => :numeric, :aliases => '-g'
      add_option "min-isoform_fraction", :type => :numeric, :aliases => '-F'
      add_option "max-insertion-length", :type => :numeric
      add_option "max-deletion-length", :type => :numeric
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
      add_option "allow-indels", :type => :boolean
      add_option "no-novel-indels", :type => :boolean
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