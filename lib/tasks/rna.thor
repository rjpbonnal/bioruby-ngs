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
    wrapper.params = {"output-dir" => outputdir, "GTF" => gtf } #"num-threads" => 6, 
    wrapper.run :arguments=>[bam], :separator => "="
  end

  desc "quantdenovo GTF_guide OUTPUTDIR BAM ", "Genes and transcripts quantification discovering de novo transcripts"
#  mehtod_option :cufftag, :type => :string
  Bio::Ngs::Cufflinks::QuantificationDenovo.new.thor_task(self, :quantdenovo) do |wrapper, task, gtf_guide, outputdir, bam|
    wrapper.params = task.options
    wrapper.params = {"output-dir" => outputdir, "GTF-guide" => gtf_guide } #"num-threads" => 6, 
    wrapper.run :arguments=>[bam], :separator => "="
    # if prefix=task.options[:cufftag]
    #   wrapper.gsub_cuff(outputdir, prefix)
    # end
  end

  desc "denovo_gsub_cuff PATH PREFIX", "Change assembled transcripts have CUFF prefix to PREFIX"
  def denovo_gsub_cuff(path, prefix)
    cuff_denovo =  Bio::Ngs::Cufflinks::QuantificationDenovo.new
    Dir.chdir(path) do 
    `tar cvfz quantification_denovo.raw.tar.gz #{cuff_denovo.ofiles.join(' ')}` unless File.exists?("quantification_denovo.raw.tar.gz")
    end
    cuff_denovo.gsub_cuff(path, prefix)
  end


  #GTFS_QUANTIFICATION is a comma separated list of gtf file names
  desc "compare GTF_REF OUTPUTDIRPREFIX GTFS_QUANTIFICATION", "GTFS_QUANTIFICATIONS, use a comma separated list of gtf"
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


  desc "merge GTF_REF FASTA_REF ASSEMBLY_GTF_LIST", "ASSEMBLY_GTF_LIST, a file which contains a list of transcript gtf from quantification"
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


  class Illumina< Thor

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
  method_option :requantify, :type => :boolean, :default => false, :desc => 'Force requantification also if the files are there.'                                                                       
  method_option "num-threads", :type => :numeric, :aliases => '-p', :default => 6
  def mapquant_illumina_trimmed(run_dir, project_name, sample_name, dist, index)

    log = Logger.new(STDOUT)

    begin
      projects = Bio::Ngs::Illumina.build(run_dir)
    rescue
      puts "Error: Run dir #{run_dir} does not exist."
    end
    begin
      project = projects.get project_name
    rescue
      puts "Error: Project #{project} does not exist"
    end
    begin
      sample = project.get sample_name
    rescue
      puts "Error: Samepl #{sample} does not exist"
    end
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
        tophat_illumina(dist, index, outputdir, "#{data_forward},#{data_reverse}")
        log.info("mapquant_illumina_trimmed: mapping over #{run_dir} #{project_name} #{sample_name}")
      end
    rescue
      puts "Error: something went wrong with tophat"
    end
    #cufflinks quantification on
    quantification_map_files = %w(genes.fpkm_tracking  isoforms.fpkm_tracking  skipped.gtf  transcripts.gtf).map do |name|
      File.join(outputdir,"quantification",name)
    end.sort

    quantification_denovo_map_files = %w(genes.fpkm_tracking  isoforms.fpkm_tracking  skipped.gtf  transcripts.gtf).map do |name|
      File.join(outputdir,"quantification_denovo",name)
    end.sort

    if !options[:requantify] && Dir.exists?(File.join(outputdir,"quantification")) && Dir.glob(File.join(outputdir,"quantification","*")).sort==quantification_map_files
      log.warn("mapquant_illumina_trimmed: skip quantification because already there")
    else 
      log.info("mapquant_illumina_trimmed: Start quantification quant #{run_dir} #{project_name} #{sample_name}")
      #invoke :quant, ["#{index}.gtf", File.join(outputdir,"quantification"), File.join(outputdir,"accepted_hits.bam")]
      FileUtils.remove_entry_secure(File.join(outputdir,'quantification')) if ( options[:requantify] &&  Dir.exists?(File.join(outputdir,"quantification")))
      invoke "rna:quant", ["#{index}.gtf", File.join(outputdir,"quantification"), File.join(outputdir,"accepted_hits.bam")]
      log.info("mapquant_illumina_trimmed: quantification over #{run_dir} #{project_name} #{sample_name}")
    end

    if !options[:requantify] && Dir.exists?(File.join(outputdir,"quantification_denovo")) && Dir.glob(File.join(outputdir,"quantification_denovo","*")).sort==quantification_denovo_map_files
      log.warn("mapquant_illumina_trimmed: skip quantification DENOVO because already there")
    else
      FileUtils.remove_entry_secure(File.join(outputdir,'quantification_denovo')) if (options[:requantify] && Dir.exists?(File.join(outputdir,"quantification_denovo")))
      log.info("mapquant_illumina_trimmed: Start quantification DENOVO  #{run_dir} #{project_name} #{sample_name}")
      invoke "rna:quantdenovo", ["#{index}.gtf", File.join(outputdir,"quantification_denovo"), File.join(outputdir,"accepted_hits.bam")], :label => sample_name #substitute CUFF with SAMPLENAME
      log.info("mapquant_illumina_trimmed: quantification DENOVO over #{run_dir} #{project_name} #{sample_name}")
    end
  end

  desc "denovo_gsub_cuff RUN PROJECT SAMPLENAME", "Change assembled transcripts have CUFF prefix to SAMPLE NAME"
  def denovo_gsub_cuff(run_dir, project_name, sample_name)
    # projects = Bio::Ngs::Illumina.build(run_dir)
    # project = projects.get project_name
    # sample = project.get sample_name      
    outputdir = File.join("MAPQUANT/#{run_dir}/Project_#{project_name}/Sample_#{sample_name}", 'quantification_denovo')
    invoke "rna:denovo_gsub_cuff", [outputdir, sample_name]
    end
  end


  # output directory is named DE plus a list of projects name separated by underscaore
  # DE_P1_P2_P3_P4
  # This task looks for every bam from the current directory and save there the output
#  cuffdiff -o DE_Naive_Th1_Th17_Th2_Treg_Tfh -b /mnt/iscsi/ngs/data/genome/ensembl/release-66/fasta/Homo_sapiens/Hsa_GRCh37_66.fa -p 10 -N -L Naive,Th1,Th17,Th2,Treg,Tfh -u /mnt/iscsi/ngs/LincRNAs_PROJECT/DATI/CuffMerge_Naive_Th1_Th17_Th2_Treg_Tfh/merged_asm/merged.gtf 110908NaiveT0/Sample_SQ_0080/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,110908NaiveT0/Sample_SQ_0081/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,110908NaiveT0/Sample_SQ_0082/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,110714Naive/TopHat_Alignment_PE_genomeV66/accepted_hits.bam 111013Th1/Sample_SQ_0007/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Th1/Sample_SQ_0046/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Th1/Sample_SQ_0047/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Th1/Sample_SQ_0048/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Th1/Sample_SQ_0050/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam 111013Th17/Sample_SQ_0011/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Th17/Sample_SQ_0051/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Th17/Sample_SQ_0052/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Th17/Sample_SQ_0053/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Th17/Sample_SQ_0055/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam 111013Th2/Sample_SQ_0014/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Th2/Sample_SQ_0015/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Th2/Sample_SQ_0056/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Th2/Sample_SQ_0058/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Th2/Sample_SQ_0059/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam 111013Treg/Sample_SQ_0021/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Treg/Sample_SQ_0022/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Treg/Sample_SQ_0023/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Treg/Sample_SQ_0065/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Treg/Sample_SQ_0067/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam 111013Tfh/Sample_SQ_0074/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Tfh/Sample_SQ_0075/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Tfh/Sample_SQ_0076
# /filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Tfh/Sample_SQ_0078/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam,111013Tfh/Sample_SQ_0079/filtered/TopHat_Alignment_PE_genomeV66/accepted_hits.bam

#### FIX ###### some parameters does not work properly like frag-bias-correct
  desc "de FASTAREF GTFMERGED PROJECTLIST", "Perform a differential expression"
  method_option :rootdir, :type => :string, :default => './', :desc => 'From where to start for looking for projects data'
  Bio::Ngs::Cufflinks::Diff.new.thor_task(self, :de) do |wrapper, task, fasta, gtf, projects_list|
    log = Logger.new(STDOUT)
    projects= Hash.new {|h,k| h[k]=[]}
     #search using symlonks too
    Dir.glob([File.join(task.options[:rootdir],'**/*/**','accepted_hits.bam')]).select do |bam_path|
      pfound = projects_list.split(',').find do |project|
        bam_path=~/Project_#{project}\//
      end
      if pfound
        projects[pfound] << bam_path
      end #if I can not find a project for a bam may be that bam is not coming from the projects of interest
    end

    projects_params=[]
    projects_list.split(',').each do |name|
      projects_params << projects[name].join(',')
    end

    wrapper.params = task.options
    wrapper.params = {"output-dir" => "DE_#{projects_list.tr(',','_')}", 
                      "frag-bias-correct" => fasta,
                      "emit-count-tables" => true,
                      "label" => projects_list,
                      "upper-quartile-norm" => true }
    #TODO: check if all the projects has data otherwise fire up a warning message.
    wrapper.run :arguments =>[gtf, projects_params.join(' ')], :separator => "="
  end 

  desc "projects_to_bams PROJECTLIST", "search for bams related to specific projest"
  method_option :rootdir, :type => :string, :default => './', :desc => 'From where to start for looking for projects data'
  def projects_to_bams(projects_list)
    log = Logger.new(STDOUT)
    projects= Hash.new {|h,k| h[k]=[]}
     #search using symlonks too
    Dir.glob([File.join(options[:rootdir],'**/*/**','accepted_hits.bam')]).select do |bam_path|
      pfound = projects_list.split(',').find do |project|
        bam_path=~/Project_#{project}\//
      end
      if pfound
        projects[pfound] << bam_path
      end #if I can not find a project for a bam may be that bam is not coming from the projects of interest
    end

    projects_params=[]
    projects_list.split(',').each do |name|
      projects_params << projects[name].join(',')
    end

    puts projects_params.join(' ')
  end 

end