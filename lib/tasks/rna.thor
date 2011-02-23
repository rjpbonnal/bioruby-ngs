class Rna < Thor
  
  #TODO : 
  # tophat alignment
  # check for required tools tophat, cufflinks, bowtie, bwa, ....
  
  desc "idx_fasta [INDEX] [FASTA]", "Create a fasta file from an indexed genome, using bowtie-inspect"
  method_option :index, :type => :string, :require => true
  method_option :fasta, :type => :string
  def idx_to_fasta
    fasta = options.fasta || "#{options.index}.fasta"
    sh "bwotie-inspect #{options.index} > #{fasta}"
  end
  
  desc "assembly", "assembly using bowtie"
  def assembly_bwt
  end

  desc "assembly", "assembly using bwa"
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

  desc "qseq_to_fastq_si [PATH]", "convert a set of qseq files in fastq, single read"
  method_option :path, :type => :string, :default => "."
  def qseq_to_fastq_si
    # TODO use code coming from Valeria
  end

  desc "qseq_to_fastq_pe [PATH]", "convert a set of qseq files in fastq, paired ends"
  method_option :path, :type => :string, :default => "."
  def qseq_to_fastq_pe
    # TODO use code coming from Valeria
    puts options.path.class
    puts options.path
  end
  
end