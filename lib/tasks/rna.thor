class Rna < Thor
  
  #TODO : 
  # tophat alignment
  # check for required tools tophat, cufflinks, bowtie, bwa, ....
  # convert bcl for illumina data
  
  desc "idx_fasta [INDEX] [FASTA]", "Create a fasta file from an indexed genome, using bowtie-inspect"
  method_option :index, :type => :string, :require => true
  method_option :fasta, :type => :string
  def idx_to_fasta
    fasta = options.fasta || "#{options.index}.fasta"
    sh "bowtie-inspect #{options.index} > #{fasta}"
  end
  
  desc "tophat_sr", "tophat alignment single reads"
  method_option :threads, :type=>:numeric, :default=>1
  def tophap_sr
    # TODO tophat --num-threads 1 --solexa1.3-quals --output-dir liver_output Homo_ sapiens/UCSC/hg18/Sequence/BowtieIndex/genome liver.fastq
  end

  desc "tophat_pe", "tophat alignment paired ends reads"
  method_option :threads, :type=>:numeric, :default=>1
  def tophap_pe
    # TODO 
  end
  
  desc "assembly_bwt", "assembly using bowtie"
  def assembly_bwt
  end

  desc "assembly_bwa", "assembly using bwa"
  def assembly_bwa
  end

  desc "cuffscmp", "make a comparison with cufflinkscompare"
  def cuffcmp
  end
  
  desc "cuffsquant", "do a complete quantification usinf cufflinks"
  def cuffcmp
  end
  
  desc "samindex", "index a genome with samtools"
  def samindex
  end

  desc "sammerge", "merge two set with samtools"
  def sammerge
  end

  desc "qseq_to_fastq_sr [PATH]", "convert a set of qseq files in fastq, single read"
  method_option :path, :type => :string, :default => "."
  def qseq_to_fastq_sr
    # TODO use code coming from Valeria
    # Bio::Ngs.qseq_to_fastq_si(path)
  end

  desc "qseq_to_fastq_pe [PATH]", "convert a set of qseq files in fastq, paired ends"
  method_option :path, :type => :string, :default => "."
  def qseq_to_fastq_pe
    # TODO use code coming from Valeria
    # Bio::Ngs.qseq_to_fastq_pe(path)
  end
  
end