class Bwa < Thor

  require 'rubygems'
  require 'bio-bwa'
  
  class Index < Bwa
	  
	  desc "short FASTA", "Make the BWT index for a SHORT FASTA database"
	  method_options :colorspace => false, :prefix => :string
	  def short(fasta)
	    real_prefix = (options[:prefix]) ? options[:prefix] : fasta
  	  Bio::BWA.make_index(:file_in => fasta, :c => options[:colorspace], :prefix => real_prefix)
	  end
	
	  desc "long FASTA", "Make the BWT index for a LONG FASTA database"
	  method_options :colorspace => false, :prefix => :string
	  def long(fasta)
      real_prefix = (options[:prefix]) ? options[:prefix] : fasta
	    Bio::BWA.make_index(:file_in => fasta, :a => "bwtsw",:c => options[:colorspace], :prefix => real_prefix)
    end
      
  end
  
  
  class Aln < Bwa
    
    desc "short FASTQ", "Run the aligment for SHORT query sequences"
    method_options :db_prefix => :required, :file_out => :string, :threads => :integer
    def short(fastq)
      real_file_out = (options[:file_out]) ? options[:file_out] : fastq+".sai"
      t = (options[:threads]) ? options[:threads] : 1
      Bio::BWA.short_read_alignment(:prefix => options[:db_prefix], :file_in => fastq, :file_out => real_file_out, :t => t)
    end
    
    desc "long FASTQ", "Run the aligment for LONG query sequences"
    method_options :db_prefix => :required, :file_out => :string, :threads => :integer
    def long(fastq)
      real_file_out = (options[:file_out]) ? options[:file_out] : fastq+".sam"
      t = (options[:threads]) ? options[:threads] : 1
      Bio::BWA.long_read_alignment(:prefix => options[:db_prefix], :file_in => fastq, :file_out => real_file_out, :t => t)
    end
    
  end


  class Sam < Bwa
    
    desc "single SAI", "Convert SAI alignment output into SAM format (single end)"
    method_options :db_prefix => :required, :fastq => :required, :file_out => :string
    def single(sai)
      Bio::BWA.sam_to_sai_single(:prefix => options[:prefix],:sai => sai, :fastq => options[:fastq], :file_out => options[:file_out])
    end
    
    desc "paired", "Convert SAI alignment output into SAM format (paired ends)"
    method_options :db_prefix => :required, :file_out => :string
    method_option :sai, :type => :array, :default => [], :required => true
    method_option :fastq, :type => :array, :default => [], :required => true
    def paired
      Bio::BWA.sam_to_sai_paired(:prefix => options[:prefix],:sai => options[:sai], :fastq => options[:fastq], :file_out => options[:file_out])
    end
    
  end

end