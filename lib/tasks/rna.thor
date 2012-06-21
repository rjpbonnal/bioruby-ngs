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
      # Followiing Illumina convention, a file with foward reads must hat a name like .*R1.fastq[.gz]
      # and the reverse with .*R2.fastq[.gz]
      fastq_files = task.options[:paired] ? ["#{fastqs}1.fastq","#{fastqs}2.fastq"]  : ["#{fastqs}"]
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


  desc "merge GTF_REF FASTA_REF ASSEMBLY_GTF_LIST", "GTFS_QUANTIFICATIONS, use a comma separated list of gtf"
  Bio::Ngs::Cufflinks::Merge.new.thor_task(self, :merge) do |wrapper, task, gtf_ref, fasta_ref, assembly_gtf_list|
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
    wrapper.params = {"ref-gtf"=>gtf_ref, "ref-sequence"=>fasta_ref}
    wrapper.run :arguments=>[assembly_gtf_list], :separator => "="
    # Dir.chdir("../")
  end

  
  desc "mapquant DIST INDEX OUTPUTDIR FASTQS", "map and quantify"
  method_option :paired, :type => :boolean, :default => false, :desc => 'Are reads paired? If you chose
                                                                         this option pass just the basename
                                                                         of the file without forward/reverse
                                                                         and .fastq'
  def mapquant(dist, index, outputdir, fastqs)
    #tophat
    #invoke :tophat, [dist, index, outputdir, fastqs], :paired=>options.paired
    tophat(dist, index, outputdir, fastqs)
    #cufflinks quantification on gtf
    #invoke :quant, ["#{index}.gtf", File.join(outputdir,"quantification"), File.join(outputdir,"accepted_hits_sort.bam")]
    quant("#{index}.gtf", File.join(outputdir,"quantification"), File.join(outputdir,"accepted_hits_sort.bam"))
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

#"DIST INDEX OUTPUTDIR FASTQS", "map and quantify"
  desc "tophat_illumina DIST INDEX OUTPUTDIR FASTQS", "run tophat as from command line, default 6 processors and then create a sorted bam indexed."
  method_option :paired, :type => :boolean, :default => false, :desc => 'Are reads paired? If you chose this option pass just the basename of the file without forward/reverse and .fastq'
  Bio::Ngs::Tophat.new.thor_task(self, :tophat_illumina) do |wrapper, task, dist, index, outputdir, fastqs|
      wrapper.params = task.options #merge passed options to the wrapper.
      pars = {"mate-inner-dist"=>dist, "output-dir"=>outputdir, "num-threads"=>6, "transcriptome-index"=>"transcriptome_data/known"}
      pars["GTF"] = "#{index}.gtf" unless Dir.exists?("transcriptome_data/known")
      wrapper.params = pars
      # Followiing Illumina convention, a file with foward reads must hat a name like .*R1.fastq[.gz]
      # and the reverse with .*R2.fastq[.gz]
      fastq_files = task.options[:paired] ? fastqs.split(',')  : ["#{fastqs}"]
      wrapper.run :arguments=>[index, fastq_files ].flatten, :separator=>"="
      #accepted_hits_bam_fn = File.join(outputdir, "accepted_hits.bam")
      #DEPRECATED tophat sort data by default 
      #task.invoke "convert:bam:sort", [accepted_hits_bam_fn] # call the sorting procedure.
  end


  desc "mapquant_illumina_trimmed RUN PROJECT SAMPLE DIST INDEX", "map and quantify starting from an Illumina directory primary analysis BioNGS"
  method_option :paired, :type => :boolean, :default => false, :desc => 'Are reads paired? If you chose
                                                                         this option pass just the basename
                                                                         of the file without forward/reverse
                                                                         and .fastq'
  def mapquant_illumina_trimmed(run_dir, project_name, sample_name, dist, index)
    require 'logger'
    log = Logger.new(STDOUT)

    projects = Bio::Ngs::Illumina.build(run_dir)
    project = projects.get project_name
    sample = project.get sample_name
    data_forward = (sample.get :trimmed_aggregated, true).get(:side,:left).first.last.metadata[:filename]
    data_reverse = (sample.get :trimmed_aggregated, true).get(:side,:right).first.last.metadata[:filename]
    abs_dir = "#{run_dir}/Project_#{project_name}/Sample_#{sample_name}"
    data_forward = File.join(abs_dir, data_forward)
    data_reverse = File.join(abs_dir, data_reverse)
    #tophat
      
    outputdir = "MAPQUANT/#{run_dir}/Project_#{project_name}/Sample_#{sample_name}"
    FileUtils.mkdir_p(outputdir) #unless File.exists?("MAPQUANT/#{run_dir}/Project_#{project_name}/Sample_#{sample_name}")
    #invoke :tophat_illumina, [dist, index, outputdir, "#{data_forward},#{data_reverse}"], :paired=>options.paired
    begin
      if File.exists?(File.join(outputdir,"accepted_hits.bam"))
        log.warn("mapquant_illumina_trimmed: skip alignment because accepted_hits.bam is there")
      else
        log.info("mapquant_illumina_trimmed: Start mapping reads against reference genome: tophat_illumina #{run_dir} #{project_name} #{sample_name}")
        tophat_illumina dist, index, outputdir, "#{data_forward},#{data_reverse}"
        log.info("mapquant_illumina_trimmed: mapping over #{run_dir} #{project_name} #{sample_name}")
      end
    rescue
    end
    #cufflinks quantification on
    quantification_map_files = %w(genes.fpkm_tracking  isoforms.fpkm_tracking  skipped.gtf  transcripts.gtf).map do |name|
      File.join(outputdir,"quantification",name)
    end.sort

    if Dir.exists?(File.join(outputdir,"quantification")) && Dir.glob(File.join(outputdir,"quantification","*")).sort==quantification_map_files
      log.warn("mapquant_illumina_trimmed: skip quantification because already there")
    else
      log.info("mapquant_illumina_trimmed: Start quantification quant #{run_dir} #{project_name} #{sample_name}")
      #invoke :quant, ["#{index}.gtf", File.join(outputdir,"quantification"), File.join(outputdir,"accepted_hits.bam")]
      quant("#{index}.gtf", File.join(outputdir,"quantification"), File.join(outputdir,"accepted_hits.bam"))
      log.info("mapquant_illumina_trimmed: quantification over #{run_dir} #{project_name} #{sample_name}")
    end
    
    if Dir.exists?(File.join(outputdir,"quantification_denovo")) && Dir.glob(File.join(outputdir,"quantification_denovo","*")).sort==quantification_map_files
      log.warn("mapquant_illumina_trimmed: skip quantification DENOVO because already there")
    else
      log.info("mapquant_illumina_trimmed: Start quantification DENOVO  #{run_dir} #{project_name} #{sample_name}")
      quantdenovo("#{index}.gtf", File.join(outputdir,"quantification_denovo"), File.join(outputdir,"accepted_hits.bam"))
      log.info("mapquant_illumina_trimmed: quantification DENOVO over #{run_dir} #{project_name} #{sample_name}")
    end
  end

end