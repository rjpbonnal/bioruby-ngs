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
      class View
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("samtools")
        add_option "output", :type => :string, :aliases => '-o'

        alias :original_run :run
        def run(opts = {:options=>{}, :arguments=>[], :output_file=>nil, :separator=>"="})
          opts[:arguments].insert(0,"view")
          opts[:arguments].insert(1,"-b")
          opts[:arguments].insert(2,"-o")
          original_run(opts)
        end
      end #View
    end #Samtools
  end #Ngs
end #Bio