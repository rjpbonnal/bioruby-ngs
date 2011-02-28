module  Bio
  module Ngs
    class Tophat < Thor

      desc 'tophat', 'tophat for alignment'
      method_option :version => true, :aliases => '-v'
      method_option :output_dir => './tophat_out', :aliases => '-o'
      method_option :min_anchor => 8, :aliases => '-a'
      method_option :splice_mismatches => 0, :aliases => '-m'
      method_option :min_intron => 50, :aliases => '-i'
      method_option :max_intront => 5000000, :aliases => '-I'
      method_option :max_multihits => 40, :aliases => '-g'
      method_option :min_isoform_fraction => 0.15, :aliases => '-F'
      method_option :solexa_quals => true
      method_option :solexa1_3_quals => true, :aliases => '--phred64_quals'
      method_option :quals => true, :aliases => '-Q'
      method_option :integer_quals => true
      def tophat
        puts options.inspect
      end #tophat
      
    end #Tophap
  end #Ngs
end #Bio


# tophat: 
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