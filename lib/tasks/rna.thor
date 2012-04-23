require File.expand_path(File.dirname(__FILE__) + '/../bio/ngs/utils')
require File.expand_path(File.dirname(__FILE__) + '/../wrapper')
require File.expand_path(File.dirname(__FILE__) + '/../bio/appl/ngs/tophat')

class Rna < Thor

  # you'll end up with 3 accept file, regular, sorted, sorted-indexed
  desc "tophat DIST INDEX OUTPUTDIR FASTQS", "run tophat as from command line, default 6 processors and then create a sorted bam indexed."
  method_option :paired, :type => :boolean, :default => false, :desc => 'Are reads paired? If you chose this option pass just the basename of the file without forward/reverse and .fastq'
  Bio::Ngs::Tophat.new.thor_task(self, :tophat) do |wrapper, task, dist, index, outputdir, fastqs|
      wrapper.params = task.options #merge passed options to the wrapper.
      wrapper.params = {"mate-inner-dist"=>dist, "output-dir"=>outputdir, "num-threads"=>6, "solexa1.3-quals"=>true}
      fastq_files = task.options[:paired] ? ["#{fastqs}_forward.fastq","#{fastqs}_reverse.fastq"]  : ["#{fastqs}"]
      wrapper.run :arguments=>[index, fastq_files ].flatten, :separator=>"="

      accepted_hits_bam_fn = File.join(outputdir, "accepted_hits.bam")
      #DEPRECATED tophat sort data by default 
      #task.invoke "convert:bam:sort", [accepted_hits_bam_fn] # call the sorting procedure.
  end

  desc "quant GTF OUTPUTDIR BAM ", "Genes and transcripts quantification"
  Bio::Ngs::Cufflinks::Quantification.new.thor_task(self, :quant) do |wrapper, task, gtf, outputdir, bam|
    wrapper.params = task.options
    wrapper.params = {"num-threads" => 6, "output-dir" => outputdir, "GTF" => gtf }
    wrapper.run :arguments=>[bam], :separator => "="
  end

  desc "quantdenovo GTF_guide OUTPUTDIR BAM ", "Genes and transcripts quantification discovering de novo transcripts"
  Bio::Ngs::Cufflinks::QuantificationDenovo.new.thor_task(self, :quantdenovo) do |wrapper, task, gtf_guide, outputdir, bam|
    wrapper.params = task.options
    wrapper.params = {"num-threads" => 6, "output-dir" => outputdir, "GTF-guide" => gtf_guide }
    wrapper.run :arguments=>[bam], :separator => "="
  end

  #GTFS_QUANTIFICATION is a comma separated list of gtf file names
  desc "compare GTF_REF OUTPUTDIR GTFS_QUANTIFICATION", "GTFS_QUANTIFICATIONS, use a comma separated list of gtf"
  Bio::Ngs::Cufflinks::Compare.new.thor_task(self, :compare) do |wrapper, task, gtf_ref, outputdir, gtfs_quantification|
    # unless Dir.exists?(outputdir)
    #   Dir.mkdir(outputdir)
    # end
    # Dir.chdir(outputdir)
    # #I assume GTS_QUANTIFICATION is a comma separated list of single gtf files
    # gtf_tracking_filename = "#{outputdir}.gtf_tracking"
    # File.open(gtf_tracking_filename, 'w') do |file|
    #   file.puts gtfs_quantification.gsub(/,/,"\n")
    # end #file
    wrapper.params = task.options
    wrapper.params = {"outprefix" => outputdir, "gtf_reference"=>gtf_ref}
    wrapper.run :arguments=>[gtfs_quantification.split(',')]
    # Dir.chdir("../")
  end
  
  desc "mapquant DIST INDEX OUTPUTDIR FASTQS", "map and quantify"
  method_option :paired, :type => :boolean, :default => false, :desc => 'Are reads paired? If you chose
                                                                         this option pass just the basename
                                                                         of the file without forward/reverse
                                                                         and .fastq'
  def mapquant(dist, index, outputdir, fastqs)
    #tophat
    invoke :tophat, [dist, index, outputdir, fastqs], :paired=>options.paired
    #cufflinks quantification on gtf
    invoke :quant, ["#{index}.gtf", File.join(outputdir,"quantification"), File.join(outputdir,"accepted_hits_sort.bam")]
  end

#TODO: write test to verify the behaviour
   desc "idx2fasta INDEX FASTA", "Create a fasta file from an indexed genome, using bowtie-inspect"
   Bio::Ngs::BowtieInspect.new.thor_task(self, :idx2fasta) do |wrapper, task, index, fasta|
     puts "Index file... #{index}"
     puts "Output file... #{fasta}"
     #Perhaps it would be better that the lib undertands by itself that the second arguments is the output file in case of stdoutput
     wrapper.run :arguments=>[index], :output_file=>fasta
   end
     
  # desc "idx_fasta [INDEX] [FASTA]", "Create a fasta file from an indexed genome, using bowtie-inspect"
  # method_option :index, :type => :string, :require => true
  # method_option :fasta, :type => :string
  # def idx_to_fasta
  #   fasta = options.fasta || "#{options.index}.fasta"
  #   sh "bowtie-inspect #{options.index} > #{fasta}"
  # end
  # 
  # desc "tophat_sr TEXT", "tophat alignment single reads"
  # method_option :threads, :type=>:numeric, :default=>1
  # def tophat_sr(text)
  #   puts self.inspect
  #   puts options.text
  #   # TODO tophat --num-threads 1 --solexa1.3-quals --output-dir liver_output Homo_ sapiens/UCSC/hg18/Sequence/BowtieIndex/genome liver.fastq
  # end
  # 
  # desc "tophat_pe", "tophat alignment paired ends reads"
  # method_option :threads, :type=>:numeric, :default=>1
  # def tophat_pe
  #   # TODO 
  # end
  # 
  # desc "assembly_bwt", "assembly using bowtie"
  # def assembly_bwt
  # end
  # 
  # desc "assembly_bwa", "assembly using bwa"
  # def assembly_bwa
  # end
  # 
  # desc "cuffscmp", "make a comparison with cufflinkscompare"
  # def cuffcmp
  # end
  # 
  # desc "cuffsquant", "do a complete quantification usinf cufflinks"
  # def cuffcmp
  # end
  # 
  # desc "samindex", "index a genome with samtools"
  # def samindex
  # end
  # 
  # desc "sammerge", "merge two set with samtools"
  # def sammerge
  # end
  # 
  # desc "qseq_to_fastq_sr [PATH]", "convert a set of qseq files in fastq, single read"
  # method_option :path, :type => :string, :default => "."
  # def qseq_to_fastq_sr
  #   # TODO use code coming from Valeria
  #   # Bio::Ngs.qseq_to_fastq_si(path)
  # end
  # 
  # desc "qseq_to_fastq_pe [PATH]", "convert a set of qseq files in fastq, paired ends"
  # method_option :path, :type => :string, :default => "."
  # def qseq_to_fastq_pe
  #   # TODO use code coming from Valeria
  #   # Bio::Ngs.qseq_to_fastq_pe(path)
  # end

end