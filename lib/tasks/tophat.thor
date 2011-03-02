#module  Bio
#  module Ngs

#require '../bio/appl/ngs/tophat'

    # class Tophat < Bio::Ngs::Tophat
    #    
    #    # desc 'params [OPTIONS] INDEX [OUTPUT]', 'test parametri'
    #    # def params(options, index, output)
    #    #  puts "opzioni #{options}"
    #    #  puts "input #{index}"
    #    #  puts "output #{output}"        
    #    # end
    # 
    # end #Tophap
#  end #Ngs
#end #Bio


# tophat: 
# TopHat maps short sequences from spliced transcripts to whole genomes.
# 
# Usage:
#     tophat [options] <bowtie_index> <reads1[,reads2,...,readsN]> [reads1[,reads2,...,readsN]] [quals1,[quals2,...,qualsN]] [quals1[,quals2,...,qualsN]]
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