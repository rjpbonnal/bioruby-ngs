#
#  
#
# Copyright:: Copyright (C) 2011
#     Francesco Strozzi <francesco.strozzi@gmail.com>
# License:: The Ruby License
#
#


class Bwa < Thor

  require 'bio-bwa'
  
  class Index < Bwa
	  
	  desc "short [FASTA]", "Make the BWT index for a SHORT FASTA database"
	  method_option :colorspace, :type => :boolean, :desc => "Index in Colorspace" 
	  method_option :prefix, :type => :string, :desc => "Database index name"
	  def short(fasta)
	    real_prefix = (options[:prefix]) ? options[:prefix] : fasta
  	  Bio::BWA.make_index(:file_in => fasta, :c => options[:colorspace], :prefix => real_prefix)
	  end
	
	  desc "long [FASTA]", "Make the BWT index for a LONG FASTA database"
	  method_option :colorspace, :type => :boolean, :desc => "Index in Colorspace" 
	  method_option :prefix, :type => :string, :desc => "Database index name"
	  def long(fasta)
      real_prefix = (options[:prefix]) ? options[:prefix] : fasta
	    Bio::BWA.make_index(:file_in => fasta, :a => "bwtsw",:c => options[:colorspace], :prefix => real_prefix)
    end
      
  end
  
  
  class Aln < Bwa
    
    desc "short [FASTQ]", "Run the aligment for SHORT query sequences"
    method_option :file_out, :type => :string, :desc => "file to write output to instead of stdout", :required => true    
    method_option :prefix, :type => :string, :desc => "Database prefix", :required => true  
    method_option :n, :type => :numeric, :desc => "max #diff (int) or missing prob under 0.02 err rate (float) [0.04]"
    method_option :o, :type => :numeric, :desc => "maximum number or fraction of gap opens [1]"
    method_option :e, :type => :numeric, :desc => "maximum number of gap extensions, -1 for disabling long gaps [-1]"
    method_option :i, :type => :numeric, :desc => "do not put an indel within INT bp towards the ends [5]"
    method_option :d, :type => :numeric, :desc => "maximum occurrences for extending a long deletion [10]"
    method_option :l, :type => :numeric, :desc => "seed length [32]"
    method_option :k, :type => :numeric, :desc => "maximum differences in the seed [2]"
    method_option :m, :type => :numeric, :desc => "maximum entries in the queue [2000000]"
    method_option :t, :type => :numeric, :desc => "number of threads [1]"
    method_option :M, :type => :numeric, :desc => "mismatch penalty [3]"
    method_option :O, :type => :numeric, :desc => "gap open penalty [11]"
    method_option :E, :type => :numeric, :desc => "gap extension penalty [4]"
    method_option :R, :type => :numeric, :desc => "stop searching when there are >INT equally best hits [30]"
    method_option :q, :type => :numeric, :desc => "quality threshold for read trimming down to 35bp [0]"
    method_option :B, :type => :numeric, :desc => "length of barcode"
    method_option :c, :type => :boolean, :desc => "input sequences are in the color space"
    method_option :L, :type => :boolean, :desc => "log-scaled gap penalty for long deletions"
    method_option :N, :type => :boolean, :desc => "non-iterative mode: search for all n-difference hits"
    method_option :I, :type => :boolean, :desc => "the input is in the Illumina 1.3+ FASTQ-like format"
    method_option :b, :type => :boolean, :desc => "the input read file is in the BAM format"
    method_option :single, :type => :boolean, :desc => "use single-end reads only (effective with -b)"
    method_option :first, :type => :boolean, :desc => "use the 1st read in a pair (effective with -b)"
    method_option :second, :type => :boolean, :desc => "use the 2nd read in a pair (effective with -b)"
    def short(fastq)
      bwa_options = options.dup
      bwa_options[:file_in] = fastq
      Bio::BWA.short_read_alignment(bwa_options.symbolize_keys)
    end
    
    desc "long [FASTQ]", "Run the aligment for LONG query sequences"
    method_option :file_out, :type => :string, :desc => "file to output results to instead of stdout", :required => true
    method_option :prefix, :type => :string, :desc => "Database prefix", :required => true    
    method_option :a, :type => :numeric, :desc => "score for a match [1]"
    method_option :b, :type => :numeric, :desc => "mismatch penalty [3]"
    method_option :q, :type => :numeric, :desc => "gap open penalty [5]"
    method_option :r, :type => :numeric, :desc => "gap extension penalty [2]"
    method_option :t, :type => :numeric, :desc => "number of threads [1]"
    method_option :w, :type => :numeric, :desc => "band width [50]"
    method_option :m, :type => :numeric, :desc => "mask level [0.50]"
    method_option :T, :type => :numeric, :desc => "score threshold divided by a [30]"
    method_option :s, :type => :numeric, :desc => "maximum seeding interval size [3]"
    method_option :z, :type => :numeric, :desc => "Z-best [1]"
    method_option :N, :type => :numeric, :desc => "seeds to trigger reverse alignment [5]"
    method_option :c, :type => :numeric, :desc => "coefficient of length-threshold adjustment [5.5]"
    method_option :H, :type => :boolean, :desc => "in SAM output, use hard clipping rather than soft"
    def long(fastq)
      bwa_options = options.dup
      bwa_options[:file_in] = fastq
      Bio::BWA.long_read_alignment(bwa_options.symbolize_keys)
    end
    
  end


  class Sam < Bwa
    
    desc "single [SAI]", "Convert SAI alignment output into SAM format (single end)"
    method_option :prefix, :type => :string, :required => true, :desc => "Database prefix"
    method_option :fastq, :type => :string, :required => true, :desc => "FastQ file"
    method_option :file_out, :type => :string, :required => true, :desc => "File to save the output"
    method_options :n => :numeric, :r => :string
    def single(sai)
      bwa_options = options.dup
      bwa_options[:sai] = sai
      Bio::BWA.sai_to_sam_single(bwa_options.symbolize_keys)
    end
    
    desc "paired", "Convert SAI alignment output into SAM format (paired ends)"
    method_option :prefix, :type => :string, :required => true, :desc => "Database prefix"
    method_option :file_out, :type => :string, :required => true, :desc => "File to save the output"
    method_option :sai, :type => :array, :required => true, :desc => "The 2 SAI files"
    method_option :fastq, :type => :array, :required => true, :desc => "The 2 Fasta/Q files"    
    method_option :a, :type => :numeric, :desc => "maximum insert size [500]"
    method_option :o, :type => :numeric, :desc => "maximum occurrences for one end [100000]"
    method_option :n, :type => :numeric, :desc => "maximum hits to output for paired reads [3]"
    method_option :N, :type => :numeric, :desc => "maximum hits to output for discordant pairs [10]"
    method_option :c, :type => :numeric, :desc => "prior of chimeric rate (lower bound) [1.0e-05]"
    method_option :r, :type => :string, :desc => "read group header line such as `@RG\tID:foo\tSM:bar' [null]"
    method_option :P, :type => :boolean, :desc => "preload index into memory (for base-space reads only)"
    method_option :s, :type => :boolean, :desc => "disable Smith-Waterman for the unmapped mate"
    method_option :A, :type => :boolean, :desc => "disable insert size estimate (force -s)"
    def paired
      Bio::BWA.sai_to_sam_paired(options.dup.symbolize_keys)
    end
    
  end

end