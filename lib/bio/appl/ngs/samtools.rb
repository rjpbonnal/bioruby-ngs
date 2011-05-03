#
#   samtools.rb - description
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <@bioruby.org>
# License:: The Ruby License
#
#
# 
# Program: samtools (Tools for alignments in the SAM format)
# Version: 0.1.16 (r963:234)
# 
# Usage:   samtools <command> [options]
# 
# Command: view        SAM<->BAM conversion
#          sort        sort alignment file
#          pileup      generate pileup output
#          mpileup     multi-way pileup
#          depth       compute the depth
#          faidx       index/extract FASTA
#          tview       text alignment viewer
#          index       index alignment
#          idxstats    BAM index stats (r595 or later)
#          fixmate     fix mate information
#          glfview     print GLFv3 file
#          flagstat    simple stats
#          calmd       recalculate MD/NM tags and '=' bases
#          merge       merge sorted alignments
#          rmdup       remove PCR duplicates
#          reheader    replace BAM header
#          cat         concatenate BAMs
#          targetcut   cut fosmid regions (for fosmid pool only)
#          phase       phase heterozygotes


module Bio
  module Ngs    
    module Samtools
            
      # Usage:   samtools view [options] <in.bam>|<in.sam> [region1 [...]]
      # 
      # Options: -b       output BAM
      #          -h       print header for the SAM output
      #          -H       print header only (no alignments)
      #          -S       input is SAM
      #          -u       uncompressed BAM output (force -b)
      #          -1       fast compression (force -b)
      #          -x       output FLAG in HEX (samtools-C specific)
      #          -X       output FLAG in string (samtools-C specific)
      #          -c       print only the count of matching records
      #          -L FILE  output alignments overlapping the input BED FILE [null]
      #          -t FILE  list of reference names and lengths (force -S) [null]
      #          -T FILE  reference sequence file (force -S) [null]
      #          -o FILE  output file name [stdout]
      #          -R FILE  list of read groups to be outputted [null]
      #          -f INT   required flag, 0 for unset [0]
      #          -F INT   filtering flag, 0 for unset [0]
      #          -q INT   minimum mapping quality [0]
      #          -l STR   only output reads in library STR [null]
      #          -r STR   only output reads in read group STR [null]
      #          -?       longer help      
      class View
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("samtools")
        add_option "output", :type => :string, :aliases => '-o'

        alias :original_run :run
        def run(opts = {:options=>{}, :arguments=>[], :output_file=>nil, :separator=>"="})
          opts[:arguments].insert(0, class_name)
          opts[:arguments].insert(1, "-b")
          opts[:arguments].insert(2, "-o")
          original_run(opts)
        end
      end #View
      
      # Usage:   samtools merge [-nr] [-h inh.sam] <out.bam> <in1.bam> <in2.bam> [...]
      # 
      # Options: -n       sort by read names
      #          -r       attach RG tag (inferred from file names)
      #          -u       uncompressed BAM output
      #          -f       overwrite the output BAM if exist
      #          -1       compress level 1
      #          -R STR   merge file in the specified region STR [all]
      #          -h FILE  copy the header in FILE to <out.bam> [in1.bam]
      # 
      # Note: Samtools' merge does not reconstruct the @RG dictionary in the header. Users
      #       must provide the correct header with -h, or uses Picard which properly maintains
      #       the header dictionary in merging.
      class Merge
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("samtools")
        
        add_option :bams, :type => :array, :required => true
        alias :original_run :run
        def run(opts = {:options=>{}, :arguments=>[], :output_file=>nil, :separator=>"="})
          opts[:arguments].insert(0, class_name)
          original_run(opts)
        end
      end #Merge
      
    end #Samtools
  end #Ngs
end #Bio