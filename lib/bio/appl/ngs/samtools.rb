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
      
      #Usage: samtools mpileup [options] in1.bam [in2.bam [...]]

      #Input options:

       #      -6           assume the quality is in the Illumina-1.3+ encoding
       #      -A           count anomalous read pairs
       #      -B           disable BAQ computation
       #      -b FILE      list of input BAM files [null]
       #      -C INT       parameter for adjusting mapQ; 0 to disable [0]
       #      -d INT       max per-BAM depth to avoid excessive memory usage [250]
       #      -E           extended BAQ for higher sensitivity but lower specificity
       #      -f FILE      faidx indexed reference sequence file [null]
       #      -G FILE      exclude read groups listed in FILE [null]
       #      -l FILE      list of positions (chr pos) or regions (BED) [null]
       #      -M INT       cap mapping quality at INT [60]
       #      -r STR       region in which pileup is generated [null]
       #      -R           ignore RG tags
       #      -q INT       skip alignments with mapQ smaller than INT [0]
       #      -Q INT       skip bases with baseQ/BAQ smaller than INT [13]

      #Output options:

      #       -D           output per-sample DP in BCF (require -g/-u)
      #       -g           generate BCF output (genotype likelihoods)
      #       -O           output base positions on reads (disabled by -g/-u)
      #       -s           output mapping quality (disabled by -g/-u)
      #       -S           output per-sample strand bias P-value in BCF (require -g/-u)
      #       -u           generate uncompress BCF output

      #SNP/INDEL genotype likelihoods options (effective with `-g' or `-u'):

      #       -e INT       Phred-scaled gap extension seq error probability [20]
      #       -F FLOAT     minimum fraction of gapped reads for candidates [0.002]
      #       -h INT       coefficient for homopolymer errors [100]
      #       -I           do not perform indel calling
      #       -L INT       max per-sample depth for INDEL calling [250]
      #       -m INT       minimum gapped reads for indel candidates [1]
      #       -o INT       Phred-scaled gap open sequencing error probability [40]
      #       -P STR       comma separated list of platforms for indels [all]

      #Notes: Assuming diploid individuals.


      class Mpileup
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("samtools")
        set_sub_program "mpileup"
        add_option :illumina13, :type => :boolean, :aliases => "-6", :desc => "assume the quality is in the Illumina-1.3+ encoding"
        add_option :anomalous, :type => :boolean, :aliases => "-A", :desc => "count anomalous read pairs"
        add_option :baq, :type => :boolean, :aliases => "-B", :desc => "disable BAQ computation"
        add_option :bam, :type => :string, :aliases => "-b", :desc => "list of input BAM files [null]"
        add_option :adjust, :type => :numeric, :aliases => "-C", :desc => "parameter for adjusting mapQ; 0 to disable [0]"
        add_option :depth, :type => :numeric, :aliases => "-d", :desc => "max per-BAM depth to avoid excessive memory usage [250]"
        add_option :extended, :type => :boolean, :aliases => "-E", :desc => "extended BAQ for higher sensitivity but lower specificity"
        add_option :file_in, :type => :string, :aliases => "-f", :desc => "faidx indexed reference sequence file [null]"
        add_option :readgroup, :type => :string, :aliases => "-G", :desc => "exclude read groups listed in FILE [null]"
        add_option :positions, :type => :string, :aliases => "-l", :desc => "list of positions (chr pos) or regions (BED) in FILE [null]"
        add_option :mapping_quality, :type => :numeric, :aliases => "-M", :desc => "cap mapping quality at INT [60]"
        add_option :region, :type => :string, :aliases => "r", :desc => "region in which pileup is generated [null]"
        add_option :ignoreRG, :type => :boolean, :aliases => "-R", :desc => "ignore RG tags"
        add_option :align_qual, :type => :numeric, :aliases => "-q", :desc => "skip alignments with mapQ smaller than INT [0]"
        add_option :base_qual, :type => :numeric, :aliases => "-Q", :desc => "skip bases with baseQ/BAQ smaller than INT [13]"
        add_option :dp, :type => :boolean, :aliases => "-D", :desc => "output per-sample DP in BCF (require -g/-u)"
        add_option :bcfout, :type => :boolean, :aliases => "-g", :desc => "generate BCF output (genotype likelihoods)"
        add_option :basepositions, :type => :boolean, :aliases => "-O", :desc => "output base positions on reads (disabled by -g/-u)"
        add_option :mapq_out, :type => :boolean, :aliases => "-s", :desc => "output mapping quality (disabled by -g/-u)"  
        add_option :strand_bias, :type => :boolean, :aliases => "-S", :desc => "output per-sample strand bias P-value in BCF (require -g/-u)"
        add_option :uncompressed, :type => :boolean, :aliases => "-u", :desc => "generate uncompress BCF output"
        add_option :gap_error, :type => :numeric, :aliases => "-e", :desc => "Phred-scaled gap extension seq error probability [20]"
        add_option :reads_fraction, :type => :numeric, :aliases => "-F", :desc => "minimum fraction of gapped reads for candidates [0.002]"
        add_option :homopolymer_errors, :type => :numeric, :aliases => "-h", :desc => "coefficient for homopolymer errors [100]"
        add_option :noindel, :type => :boolean, :aliases => "-I", :desc => "do not perform indel calling"
        add_option :sample_depth, :type => :numeric, :aliases => "-L", :desc => "max per-sample depth for INDEL calling [250]"
        add_option :min_gap, :type => :numeric, :aliases => "-m", :desc => "minimum gapped reads for indel candidates [1]"
        add_option :gap_open, :type => :numeric, :aliases, => "-o", :desc => "Phred-scaled gap open sequencing error probability [40]"
        add_option :indel_platforms, :type => :string, :aliases => "-P", :desc => "comma separated list of platforms for indels [all]"
      end #mpileup

      class Faidx
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("samtools")
        set_sub_program "faidx" 
      end #faidx


    end #Samtools
  end #Ngs
end #Bio