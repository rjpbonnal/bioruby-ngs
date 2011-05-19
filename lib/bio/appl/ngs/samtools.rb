#
#   samtools.rb - description
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>
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
        set_sub_program "view"
        use_aliases
        add_option :bam_output, :type => :boolean, :aliases => "-b", :desc => "output BAM", :default => true
        add_option :print_header_alignment, :type => :boolean, :aliases => "-h", :desc => "print header for the SAM output"
        add_option :print_header_only, :type => :boolean, :aliases => "-H", :desc => "print header only (no alignments)"
        add_option :sam_input, :type => :boolean, :aliases => "-S", :desc => "input is SAM"
        add_option :uncompress, :type => :boolean, :aliases => "-u", :desc => "uncompressed BAM output (force -b)"
        add_option :compress, :type => :boolean , :aliases => "-1", :desc => "fast compression (force -b)"
        add_option :flag_hex, :type => :boolean, :aliases => "-x", :desc => "output FLAG in HEX (samtools-C specific)"
        add_option :flag_string, :type => :boolean, :aliases => "-X", :desc => "output FLAS is string (samtools-C specific)"
        add_option :output_alignment, :type => :string, :aliases => "-L", :desc => "output alignments overlapping the input BED FILE [null]"
        add_option :list_ref, :type => :string, :aliases => "-t", :desc => "list of reference names and lengths (force -S) [null]"
        add_option :ref_sequence, :type => :string, :aliases => "-T", :desc => "reference sequence file (force -S) [null]"
        add_option :output, :type => :string, :aliases => "-o", :desc => "output file name [stdout]", :required => true
        add_option :list_group, :type => :string, :aliases => "-R", :desc => "list of read groups to be outputted [null]"
        add_option :required_flag, :type => :numeric, :aliases => "-f", :desc => "required flag, 0 for unset [0]"
        add_option :filtering_flag, :type => :numeric, :aliases => "-F", :desc => "filtering flag, 0 for unset [0]"
        add_option :min_map_qual, :type => :numeric, :aliases => "-q", :desc => "minimum mapping quality [0]"
        add_option :only_lib_reads, :type => :string, :aliases => "-l", :desc => "only output reads in library STR [null]"
        add_option :only_grp_reads, :type => :string, :aliases => "r", :desc => "only output reads in read group STR [null]"

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
      #out, in1, in2, ... inx Must be passed as arguments
      class Merge
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("samtools")
        set_sub_program "merge"
        use_aliases
        add_option :sort_by_read_name, :type => :boolean, :aliases => "-n", :desc => "sort by read names"
        add_option :attach_rg, :type => :boolean, :aliases => "-r", :desc => "attach RG tag (inferred from file names)"
        add_option :uncompress, :type => :boolean, :aliases => "-u", :desc => "uncompressed BAM output"
        add_option :overwrite_output, :type => :boolean, :aliases => "-f", :desc => "overwrite the output BAM if exist"
        add_option :compress, :type => :boolean , :aliases => "-1", :desc => "compress level 1"
        add_option :merge_regions, :type => :string, :aliases => "-R", :desc => "merge file in the specified region STR [all]"
        add_option :copy_header, :type => :string, :aliases => "-h", :desc => "copy the header in FILE to <out.bam> [in1.bam]"
      end #Merge
      
    end #Samtools
  end #Ngs
end #Bio