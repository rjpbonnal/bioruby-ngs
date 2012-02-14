#
#   bwa.rb - description
#
# Copyright:: Copyright (C) 2011
#     Francesco Strozzi <francesco.strozzi@gmail.com>
# License:: The Ruby License
#
#
# 
# Program: bwa (alignment via Burrows-Wheeler transformation)
# Version: 0.6.0-r85
# 

#Usage:   bwa <command> [options]
#
#Command: index         index sequences in the FASTA format
#         aln           gapped/ungapped alignment
#         samse         generate alignment (single ended)
#         sampe         generate alignment (paired ended)
#         bwasw         BWA-SW for long queries
#         fastmap       identify super-maximal exact matches
#
#         fa2pac        convert FASTA to PAC format
#         pac2bwt       generate BWT from PAC
#         pac2bwtgen    alternative algorithm for generating BWT
#         bwtupdate     update .bwt to the new format
#         bwt2sa        generate SA from BWT and Occ
#         pac2cspac     convert PAC to color-space PAC
#         stdsw         standard SW/NW alignment


module Bio
  module Ngs    
    module Bwa
            
      #Usage:   bwa index [-a bwtsw|div|is] [-c] <in.fasta>
      #
      #Options: -a STR    BWT construction algorithm: bwtsw or is [is]
      #         -p STR    prefix of the index [same as fasta name]
      #         -c        build color-space index
                   
      class Index
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("bwa")
        set_sub_program "index"
        use_aliases
        add_option :algorithm, :type => :string, :aliases => "-a", :desc => "BWT construction algorithm: bwtsw or is [is]"
        add_option :prefix, :type => :string, :aliases => "-p", :desc => "prefix of the index [same as fasta name]"
        add_option :colorspace, :type => :boolean, :aliases => "-c", :desc => "build color-space index"
      end #Index


      #Usage:   bwa aln [options] <prefix> <in.fq>
      #
      #Options: -n NUM    max #diff (int) or missing prob under 0.02 err rate (float) [0.04]
      #         -o INT    maximum number or fraction of gap opens [1]
      #         -e INT    maximum number of gap extensions, -1 for disabling long gaps [-1]
      #         -i INT    do not put an indel within INT bp towards the ends [5]
      #         -d INT    maximum occurrences for extending a long deletion [10]
      #         -l INT    seed length [32]
      #         -k INT    maximum differences in the seed [2]
      #         -m INT    maximum entries in the queue [2000000]
      #         -t INT    number of threads [1]
      #         -M INT    mismatch penalty [3]
      #         -O INT    gap open penalty [11]
      #         -E INT    gap extension penalty [4]
      #         -R INT    stop searching when there are >INT equally best hits [30]
      #         -q INT    quality threshold for read trimming down to 35bp [0]
      #         -f FILE   file to write output to instead of stdout
      #         -B INT    length of barcode
      #         -c        input sequences are in the color space
      #         -L        log-scaled gap penalty for long deletions
      #         -N        non-iterative mode: search for all n-difference hits (slooow)
      #         -I        the input is in the Illumina 1.3+ FASTQ-like format
      #         -b        the input read file is in the BAM format
      #         -0        use single-end reads only (effective with -b)
      #         -1        use the 1st read in a pair (effective with -b)
      #         -2        use the 2nd read in a pair (effective with -b)
      #         -Y        filter Casava-filtered sequences

      class Aln
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("bwa")
        set_sub_program "aln"
        use_aliases
        add_option :num, :type => :numeric, :aliases => "-n", :desc => "max #diff (int) or missing prob under 0.02 err rate (float) [0.04]"
        add_option :gap_open, :type => :numeric, :aliases => "-o", :desc => "maximum number or fraction of gap opens [1]"
        add_option :gap_ext, :type => :numeric, :aliases => "-e", :desc => "maximum number of gap extensions, -1 for disabling long gaps [-1]"
        add_option :indel, :type => :numeric, :aliases => "-i", :desc => "do not put an indel within INT bp towards the ends [5]"
        add_option :extending_deletion, :type => :numeric, :aliases => "-d", :desc => "maximum occurrences for extending a long deletion [10]"
        add_option :seed_length, :type => :numeric, :aliases => "-l", :desc => "seed length [32]"
        add_option :seed_diff, :type => :numeric, :aliases => "-k", :desc => "maximum differences in the seed [2]"
        add_option :queue, :type => :numeric, :aliases => "-m", :desc => "maximum entries in the queue [2000000]"
        add_option :threads, :type => :numeric, :aliases => "-t", :desc => "number of threads [1]"
        add_option :mismatch_penalty, :type => :numeric, :aliases => "-M", :desc => "mismatch penalty [3]"
        add_option :gap_open_penalty, :type => :numeric, :aliases => "-O", :desc => "gap open penalty [11]"
        add_option :gap_extension_penalty, :type => :numeric, :aliases => "-E", :desc => "gap extension penalty [4]"
        add_option :best_hit, :type => :numeric, :aliases => "-R", :desc => "stop searching when there are >INT equally best hits [30]"
        add_option :quality_trimming, :type => :numeric, :aliases => "-q", :desc => "quality threshold for read trimming down to 35bp [0]"
        add_option :file_out, :type => :string, :aliases => "-f", :desc => "file to write output to instead of stdout"
        add_option :barcode_length, :type => :numeric, :aliases => "-B", :desc => "length of barcode"
        add_option :colorspace, :type => :boolean, :aliases => "-c", :desc => "input sequences are in the color space"
        add_option :log_scale_penalty, :type => :boolean, :aliases => "-L", :desc => "log-scaled gap penalty for long deletions"
        add_option :non_iterative, :type => :boolean, :aliases => "-N", :desc => "non-iterative mode: search for all n-difference hits"
        add_option :illumina_13, :type => :boolean, :aliases => "-I", :desc => "the input is in the Illumina 1.3+ FASTQ-like format"
        add_option :bam, :type => :boolean, :aliases => "-b", :desc => "the input read file is in the BAM format"
        add_option :single, :type => :boolean, :aliases => "-0", :desc => "use single-end reads only (effective with -b)"
        add_option :first, :type => :boolean, :aliases => "-1", :desc => "use the 1st read in a pair (effective with -b)"
        add_option :second, :type => :boolean, :aliases => "-2", :desc => "use the 2nd read in a pair (effective with -b)"
        add_option :filter, :type => :boolean, :aliases => "-Y", :desc => "filter Casava-filtered sequences"
      end # Aln
      
      
      # Usage: bwa samse [-n max_occ] [-f out.sam] [-r RG_line] <prefix> <in.sai> <in.fq>
      
      class Samse
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("bwa")
        set_sub_program "samse"
        use_aliases
        add_option :max_occ, :type => :numeric, :aliases => "-n", :desc => "max_occ"
        add_option :file_out, :type => :string, :aliases => "-f", :desc => "file name to save data"
        add_option :rg_line, :type => :string, :aliases => "-r", :desc => "RG line"   
      end #Samse
      
      
      
      #Usage:   bwa sampe [options] <prefix> <in1.sai> <in2.sai> <in1.fq> <in2.fq>
      #
      #Options: -a INT   maximum insert size [500]
      #         -o INT   maximum occurrences for one end [100000]
      #         -n INT   maximum hits to output for paired reads [3]
      #         -N INT   maximum hits to output for discordant pairs [10]
      #         -c FLOAT prior of chimeric rate (lower bound) [1.0e-05]
      #         -f FILE  sam file to output results to [stdout]
      #         -r STR   read group header line such as `@RG\tID:foo\tSM:bar' [null]
      #         -P       preload index into memory (for base-space reads only)
      #         -s       disable Smith-Waterman for the unmapped mate
      #         -A       disable insert size estimate (force -s)
      
      class Sampe
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("bwa")
        set_sub_program "sampe"
        use_aliases    
        add_option :max_insert, :type => :numeric, :aliases => "-a", :desc => "maximum insert size [500]"
        add_option :max_occurrences, :type => :numeric, :aliases => "-o", :desc => "maximum occurrences for one end [100000]"
        add_option :max_hits, :type => :numeric, :aliases => "-n", :desc => "maximum hits to output for paired reads [3]"
        add_option :max_hits_discordant, :type => :numeric, :aliases => "-N", :desc => "maximum hits to output for discordant pairs [10]"
        add_option :chimeric_rate, :type => :numeric, :aliases => "-c", :desc => "prior of chimeric rate (lower bound) [1.0e-05]"
        add_option :file_out, :type => :string, :aliases => "-f", :desc => "sam file to output results to [stdout]"
        add_option :read_group, :type => :string, :aliases => "-r", :desc => "read group header line such as `@RG\tID:foo\tSM:bar' [null]"
        add_option :preload_index, :type => :boolean, :aliases => "-P", :desc => "preload index into memory (for base-space reads only)"
        add_option :disable_sw, :type => :boolean, :aliases => "-s", :desc => "disable Smith-Waterman for the unmapped mate"
        add_option :disable_insert_estimate, :type => :boolean, :aliases => "-A", :desc => "disable insert size estimate (force -s)"
      end #Sampe
      
      
      #Usage:   bwa bwasw [options] <target.prefix> <query.fa> [query2.fa]
      #
      #Options: -a INT   score for a match [1]
      #         -b INT   mismatch penalty [3]
      #         -q INT   gap open penalty [5]
      #         -r INT   gap extension penalty [2]
      #
      #         -t INT   number of threads [1]
      #
      #         -w INT   band width [50]
      #         -m FLOAT mask level [0.50]
      #
      #         -T INT   score threshold divided by a [30]
      #         -s INT   maximum seeding interval size [3]
      #         -z INT   Z-best [1]
      #         -N INT   # seeds to trigger reverse alignment [5]
      #         -c FLOAT coefficient of length-threshold adjustment [5.5]
      #         -H       in SAM output, use hard clipping rather than soft
      #         -f FILE  file to output results to instead of stdout
      
      class Bwasw
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("bwa")
        set_sub_program "bwasw"
        use_aliases
        add_option :paired, :type => :string, :desc => "paired reads"
        add_option :match_score, :type => :numeric, :aliases => "-a", :desc => "score for a match [1]"
        add_option :mismatch_penalty, :type => :numeric, :aliases => "-b", :desc => "mismatch penalty [3]"
        add_option :gap_open_penalty, :type => :numeric, :aliases => "-q", :desc => "gap open penalty [5]"
        add_option :gap_ext_penalty, :type => :numeric, :aliases => "-r", :desc => "gap extension penalty [2]"
        add_option :threads, :type => :numeric, :aliases => "-t", :desc => "number of threads [1]"
        add_option :band_width, :type => :numeric, :aliases => "-w", :desc => "band width [50]"
        add_option :mask_level, :type => :numeric, :aliases => "-m", :desc => "mask level [0.50]"
        add_option :score_threshold, :type => :numeric, :aliases => "-T", :desc => "score threshold divided by a [30]"
        add_option :max_seeding, :type => :numeric, :aliases => "-s", :desc => "maximum seeding interval size [3]"
        add_option :z_best, :type => :numeric, :aliases => "-z", :desc => "Z-best [1]"
        add_option :seed_reverse, :type => :numeric, :aliases => "-N", :desc => "seeds to trigger reverse alignment [5]"
        add_option :length_threshold, :type => :numeric, :aliases => "-c", :desc => "coefficient of length-threshold adjustment [5.5]"
        add_option :hard_clip, :type => :boolean, :aliases => "-H", :desc => "in SAM output, use hard clipping rather than soft"
        add_option :file_out, :type => :string, :aliases => "-f", :desc => "file to output results to instead of stdout"
      end
      
      # Usage: bwa fastmap [-l minLen=17] [-w maxSaSize=20] <idxbase> <in.fq>
      class Fastmap
        include Bio::Command::Wrapper
        set_program Bio::Ngs::Utils.binary("bwa")
        set_sub_program "fastmap"
        use_aliases
        add_option :min_length, :type => :numeric, :aliases => "-l", :desc => "minLen [17]"
        add_option :max_sa_size, :type => :numeric, :aliases => "-w", :desc => "maxSaSize [20]"        
      end
      
    end #Bwa
  end #Ngs
end #Bio