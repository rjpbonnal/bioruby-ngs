# bio-ngs

Provides a framework for handling NGS data with Bioruby.

## Features & Aims
* Supports many tools for NGS: SAMtools, BWA, Bowtie, TopHat, Cufflinks
* Avoids conflicts: required tools and libraries are installed in a sandbox
* Detect pre insalled software at runtime 
* Reporting: text and graphs
* Simple API for developing your own scripts in Ruby


## Requirements
* http://hannonlab.cshl.edu/fastx_toolkit/ (the gem tries to install this tool by itself)
* http://www.gnuplot.info/ tested on version 4.6
* libxslt1-dev
* CASAVA 1.8.2 <http://support.illumina.com/sequencing/sequencing_software/casava.ilmn>
* Java SE for running Trimmomatic
* pigz A parallel implementation of gzip for modern multi-processor, multi-core machines <http://zlib.net/pigz/>

## Install
### Quick Start
    gem install bio-ngs
* Gems dependencies resolved by RubyGems
* External software will be downloaded, compiled and installed in a sandbox
* No root grants required, no conflict with pre installed applications

### Do not install third party software
    gem install bio-ngs -- --no-third-party

* Using system wide software

Pleas follow the instruction for your own distribution/operating system



## Tasks
We'll try to keep this list updated but just in case type `biongs -T` to get the most updated list.  
_We are working on these and other tasks, if you find some bugs, please open an issue on Github._

### bwa

    biongs bwa:aln [PREFIX] [FASTA/Q]                                                      # Run BWA aln (short reads)
    biongs bwa:bwasw [PREFIX] [FASTA/Q]                                                    # Run BWA bwasw (long reads)
    biongs bwa:fastmap [PREFIX] [FASTA/Q]                                                  # Run BWA Fastmap (identify super-maximal exact matches)
    biongs bwa:index [FASTA]                                                               # Create BWA index
    biongs bwa:sampe [PREFIX] [SAI-1 FILE] [SAI-2 FILE] [FASTA/Q-1 FILE] [FASTA/Q-2 FILE]  # Run BWA SAM Paired End conversion
    biongs bwa:samse [PREFIX] [SAI FILE] [FASTA/Q FILE]                                    # Run BWA SAM Single End conversion

### convert
Most of this tasks create sub-processes to speed up conversions

    biongs convert:bam:extract_genes BAM GENES --ensembl-release=N -o, --output=OUTPUT  # Extract GENES from bam. It connects to Ensembl Humnan,...
    biongs convert:bam:merge -i, --input-bams=one two three                             # Merge multiple bams in a single one, BAMS separated by...
    biongs convert:bam:sort BAM [PREFIX]                                                # Sort and create and index for the BAM file name
    biongs convert:bcl:fastq:configure_conversion RUNDIR DATAOUTDIR                     # Configure the specific Run to be converted
    biongs convert:bcl:fastq:convert RUNDIR DATAOUTDIR [SAMPLESHEET]                    # Convert a bcl dataset in fastq. By default it creates a
                                                                                          directory with the same name of the dir attachin...
    biongs convert:bcl:fastq:start_conversion CONF_DATA_DIR                             # Start the conversion
    biongs convert:bcl:qseq:convert RUN OUTPUT [JOBS]                                   # Convert a bcl dataset in qseq
    biongs convert:illumina:de:gene DIFF GTF                                            # extract the transcripts
    biongs convert:illumina:de:isoform DIFF GTF                                         # extract the transcripts
    biongs convert:illumina:de:rename_qs DIFF_FILE NAMES                                # rename q1,...,qn with names provided by the user(comma...
    biongs convert:illumina:fastq:trim_b FASTQ                                          # perform a trim on all the sequences on B qualities wit...
    biongs convert:illumina:humanize:build_compare_kb GTF                               # Build the JSON file with the annoation from the GTF fi...
    biongs convert:illumina:humanize:isoform_exp GTF ISOFORM                            # tag the XLOC gathering information from GTF (ensembl)
    biongs convert:qseq:fastq:by_file FIRST OUTPUT                                      # Convert a qseq file into fastq
    biongs convert:qseq:fastq:by_lane LANE OUTPUT                                       # Convert all the file in the current and descendant dir...
    biongs convert:qseq:fastq:by_lane_index LANE INDEX OUTPUT                           # Convert the qseq from a line and index in a fastq file
    biongs convert:qseq:fastq:samples_by_lane SAMPLES LANE OUTPUT                       # Convert the qseqs for each sample in a specific lane. 
                                                                                          SAMPLES is an array of index codes separated by commas lane
                                                                                          is an integer




### filter

    biongs filter:by_list TABLE LIST            # Extract from TABLE the row with a key in LIST
    biongs filter:cufflinks:tra_at_idx GTF IDX  # Extract transcript(s) from Cufflinks' GTF at a specific location or givin the transcript name,...
    biongs filter:cufflinks:transcripts [GTF]   # Extract transcripts from Cufflinks' GTF

### history

    biongs history:clear  # Wipe out the tasks history

### homology

    biongs homology:convert:blast2text [XML FILE] --file-out=FILE_OUT  # Convert Blast output to tab-separated file
    biongs homology:convert:go2json                                    # Convert the GO annotations from the db into a JSON file
    biongs homology:db:export [TABLE] --fileout=FILEOUT                # Export the data from a table to a tab-separated file
    biongs homology:db:init                                            # Initialize Homology DB
    biongs homology:download:all                                       # Download the Uniprot and GO Annotation file
    biongs homology:download:goannotation                              # Download the Uniprot GeneOntology Annotation file
    biongs homology:download:uniprot                                   # Download the Uniprot-SwissProt file from UniprotKB
    biongs homology:load:blast [FILE]                                  # Parse Blast XML output and load the results into Homology DB
    biongs homology:load:goa                                           # Import GO Annotation file
    biongs homology:report:blast                                       # Output a graphical report on the Blast homology search

### install

    biongs install:tools  # Download and install NGS tools

### ontology

    biongs ontology:db:export [TABLE] --fileout=FILEOUT  # Export the data from a table to a tab-separated file
    biongs ontology:db:init                              # Initialize Ontology DB
    biongs ontology:download:all                         # Download the GO files
    biongs ontology:download:go                          # Download the GeneOntology file
    biongs ontology:download:goslim                      # Download the Uniprot GeneOntology Slim file
    biongs ontology:load:genego [FILE]                   # Import Gene-GO file (JSON)
    biongs ontology:load:go [FILE]                       # Import GO definition file
    biongs ontology:report:go                            # Output a graphical report on the GO for the sequences annotated in the db

### pre

    biongs pre:illumina_filter [DIR(s)]  # Filter the data using Y/N flag in FastQ headers (Illumina). Search for fastq.gz files within director...
    biongs pre:merge [file(s)]           # Merge together fastQ files (accepts wildcards)
    biongs pre:paired_merge [file(s)]    # Merge together FastQ files while checking for correct pairing (accepts wildcards)
    biongs pre:trim [fastq(s)]           # Calulate quality profile and trim the all the reads using FastX (accepts wildcards)
    biongs pre:uncompress [file(s)]      # Uncompress multiple files in parallel (accepts wildcards)

### project

    biongs project:new [NAME]     # Create a new NGS project directory

### quality

    biongs quality:boxplot FASTQ_QUALITY_STATS                   # plot reads quality as boxplot
    biongs quality:fastq_stats FASTQ                             # Reports quality of FASTQ file
    biongs quality:illumina_b_profile_raw FASTQ --read-length=N  # perform a profile for reads coming fom Illumina 1.5+ and write the report in ...
    biongs quality:illumina_b_profile_svg FASTQ --read-length=N  # perform a profile for reads coming fom Illumina 1.5+
    biongs quality:illumina_projects_stats                       # Reports quality of FASTQ files in an Illumina project directory
    biongs quality:nucleotide_distribution FASTQ_QUALITY_STATS   # plot reads quality as boxplot
    biongs quality:quality_trim FASTQ                            # Trim all the sequences using quality information
    biongs quality:reads FASTQ                                   # perform quality check for NGS reads
    biongs quality:reads_coverage FASTQ_QUALITY_STATS            # plot reads coverage in bases
    biongs quality:scatterplot EXPR1 EXPR2 OUTPUT                # plot quantification values as scatterplot in png format

### rna

    biongs rna:compare GTF_REF OUTPUTDIR GTFS_QUANTIFICATION  # GTFS_QUANTIFICATIONS, use a comma separated list of gtf
    biongs rna:idx2fasta INDEX FASTA                          # Create a fasta file from an indexed genome, using bowtie-inspect
    biongs rna:mapquant DIST INDEX OUTPUTDIR FASTQS           # map and quantify
    biongs rna:merge GTF_REF FASTA_REF ASSEMBLY_GTF_LIST      # GTFS_QUANTIFICATIONS, use a comma separated list of gtf
    biongs rna:quant GTF OUTPUTDIR BAM                        # Genes and transcripts quantification
    biongs rna:quantdenovo GTF_guide OUTPUTDIR BAM            # Genes and transcripts quantification discovering de novo transcripts
    biongs rna:tophat DIST INDEX OUTPUTDIR FASTQS             # run tophat as from command line, default 6 processors and then create a sorted b...

### sff

    biongs sff:extract [FILE]  # Run sff_extract on a SFF file

## TasksExamples

### Conversion

#### Extract gene(s) alignment from a BAM

   biongs convert:bam:extract_genes your_original.bam BLID,GATA3,PTPRC --ensembl_release=61 --ensembl_specie=homo_sapiens

#### Demultiplex an Illumina Run.
By default Illumina uses `SampleSheet.csv` in the `your_run/Data/Intensities/BaseCalls` file to describe the layout of your run

    FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject
    D0C0DACXX,1,0113,Ensembl,CGATGT,Y1,N,R2,Doe,X
    D0C0DACXX,1,0114,Ensembl,TGACCA,Y1,N,R2,Doe,X
    D0C0DACXX,1,0115,Ensembl,ACAGTG,X1,N,R2,Doe,Y
    D0C0DACXX,1,0116,Ensembl,GCCAAT,X1,N,R2,Doe,Y
    D0C0DACXX,2,0117,Ensembl,CGATGT,Y1,N,R2,Doe,X
    D0C0DACXX,2,0118,Ensembl,TGACCA,Y1,N,R2,Doe,X
    D0C0DACXX,2,0119,Ensembl,ACAGTG,X1,N,R2,Doe,Y
    D0C0DACXX,2,0120,Ensembl,GCCAAT,X1,N,R2,Doe,Y
    D0C0DACXX,3,0121,Ensembl,CGATGT,Y1,N,R2,Doe,X
    D0C0DACXX,3,0122,Ensembl,TGACCA,Y1,N,R2,Doe,X
    D0C0DACXX,3,0123,Ensembl,ACAGTG,X1,N,R2,Doe,Y
    D0C0DACXX,3,0124,Ensembl,GCCAAT,X1,N,R2,Doe,Y
    D0C0DACXX,4,0125,Ensembl,CGATGT,Y1,N,R2,Doe,X
    D0C0DACXX,4,0126,Ensembl,TGACCA,Y1,N,R2,Doe,X
    D0C0DACXX,4,0127,Ensembl,ACAGTG,X1,N,R2,Doe,Y
    D0C0DACXX,4,0128,Ensembl,GCCAAT,X1,N,R2,Doe,Y
    D0C0DACXX,5,0095,Ensembl,ATCACG,Y1,N,R2,Doe,X
    D0C0DACXX,5,0096,Ensembl,TTAGGC,Y1,N,R2,Doe,X
    D0C0DACXX,5,0097,Ensembl,ACTTGA,X1,N,R2,Doe,Y
    D0C0DACXX,5,0098,Ensembl,GATCAG,X1,N,R2,Doe,Y
    D0C0DACXX,6,0109,Ensembl,ACTTGA,Y1,N,R2,Doe,X
    D0C0DACXX,6,0110,Ensembl,GATCAG,Y1,N,R2,Doe,X
    D0C0DACXX,6,0111,Ensembl,TAGCTT,X1,N,R2,Doe,Y
    D0C0DACXX,6,0112,Ensembl,GGCTAC,X1,N,R2,Doe,Y
    D0C0DACXX,7,0129,Ensembl,CGATGT,Y1,N,R2,Doe,X
    D0C0DACXX,7,0130,Ensembl,TGACCA,Y1,N,R2,Doe,X
    D0C0DACXX,7,0131,Ensembl,ACAGTG,X1,N,R2,Doe,Y
    D0C0DACXX,7,0132,Ensembl,GCCAAT,X1,N,R2,Doe,Y
    D0C0DACXX,8,0133,Ensembl,CGATGT,Y1,N,R2,Doe,X
    D0C0DACXX,8,0134,Ensembl,TGACCA,Y1,N,R2,Doe,X
    D0C0DACXX,8,0135,Ensembl,ACAGTG,X1,N,R2,Doe,Y
    D0C0DACXX,8,0136,Ensembl,GCCAAT,X1,N,R2,Doe,Y

We expect to find `SampleSheet.csv` in your run directory, in case of a custom name user can pass it as last parameter `--sample_sheet=your_sample_sheet.csv`.  
To demultiplex your experiment

    ngs biongs convert:bcl:fastq:convert /bio/ngs/raw/110321_H001_0100_AD10TMACXX/ /bio/ngs/data/110321_H001_0100_AD10TMACXX_DATA --cpu=8 > 110321_H125_0100_AD10TMACXX.log 2>&1

This command will save the stdout on a log file in the current directory. You must specify the source directory and the destination. You can select the number of CPU to use for demultiplexing, 8 is the maximum value becase 8 lanes.  
Typing `biongs help convert:bcl:fastq:convert` you can have a list of sub tasks. Where `biongs convert:bcl:fastq:configure_conversion RUNDIR DATAOUTDIR` corresponds to `configureBclToFastq.pl`and `biongs convert:bcl:fastq:start_conversion` to `make` in the demultiplexed directory. 

### Filtering
When you have your mapped reads to a reference genome, you can decide to filter the output (GTF) to extract only those transcripts which have your desired requirements. You can filter for lenght, if it's multi or mono exon, the coverage, if it's a brand new transcript or an altrady annotated gene but with a new isoform or just the annotated transcripts.

    Scenario: filtering transcripts
    Having a transcripts.gtf dataset generated from CufflinksQuantification
    I want a only the new transcripts (also with an annotated gene)
    Which are multi exons
    With a lenght greater than 1340
    With minimum coverage greater than 10
    Then I want to save them in my_filtered_data.gtf
***
    biongs filter:cufflinks:transcripts your_original.gtf -m -l 1340 -c 10.0 -n -o my_filtered_data.gtf

Then in some case I need to extract only some of them or maybe parsing them from external programs. Biongs has a specific trask for this:

    Having my_filtered_data.gtf
    Generated by "filtering transcripts"
    I want to extract transcript number 10
    Then I want to save it in BED format
    Using UCSC notation
***
    biongs filter:cufflinks:tra_at_idx my_filtered_data.gtf #of_the_transcript_to_retrieve -u 

The first time tra_at_idx is used, it will take more time than usual becase it creates an internal index: a simple HASH mashalled and dumped, stored in a file with the name similar to the imput with an idx as postfix.

### Interacting with the FileSystem

Following the concept of convention over configuration BioNGS can discover types of files in your project directory. Suppose you have trimmed fastq  (`rtf`) from a project and you want to select just the forward trimmed fastq files:

    biongs smart:data Project rtf "|:Sample1:Sample2:Sample3:Sample4:Sample5" --root path_to_your_data_directory

you'll get the list of files with this this features.
To speed up the search, discovered and tagged files are dumped locally in `path_to_your_data_directory` under `conf` directory.

#### Type of files

Biongs has predefined tag system. In the future it will be more general and a custom configuration file will be accepted. In the mean time, these are the 
predefined tags

    CATEGORIES ={
                :cufflinks=>{rules:[/genes\.fpkm_traking/, #same for denovo
                             /isoforms\.fpkm_traking/, #same for denovo
                             /transcripts\.gtf/, #same for denovo
                             /skipped\.gtf/,
                             /genes\.fpkm_tracking/,
                             /isoforms\.fpkm_tracking/]}, #same for denovo
                  
                :cuffdiff=>{rules:[/.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*cds\.diff/,
                            /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*cds_exp\.diff/,
                           /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*cds\.fpkm_tracking/,
                           /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*gene_exp\.diff/,
                           /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*genes\.fpkm_tracking/,
                           /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*isoform_exp\.diff/,
                           /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*isoforms\.fpkm_tracking/,
                           /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*promoters\.diff/,
                           /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*splicing\.diff/,
                           /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*tss_group_exp\.diff/,
                           /.*\/(DE|de|cuffdiff|differential|differentialexpression)\/.*tss_groups\.fpkm_tracking/]},
                :quantification =>{rules:[/quantification/]},
                :cuffcompare =>{rules:[/.*(compare).*\.tracking/,
                               /.*(compare).*\.combined\.gtf/,
                               /.*(compare).*\.loci/,
                               /.*(compare).*\.stats/]},
                :tophat => {rules:[/accepted_hits\.bam$/,
                            /deletions\.bed/,
                            /insertions\.bed/,
                            /junctions\.bed/,
                            /left_kept_reads\.info/,
                            /right_kept_reads\.info/,
                            /unmapped_left\.fq\.z/,
                            /unmapped_right\.fq\.z/
                            ]},
                :rtfc => {rules:[/_L\d{3,3}_R1_\d{3,3}\.trimmed\.fastq\.gz/]}, #reads_trimmed_forward_chunks
                :rtrc => {rules:[/_L\d{3,3}_R2_\d{3,3}\.trimmed\.fastq\.gz/]}, #reads_trimmed_reverse_chunks
                :rtf => {rules:[/_R1\.trimmed\.fastq\.gz/]}, #reads_trimmed_forward
                :rtr => {rules:[/_R2\.trimmed\.fastq\.gz/]}, #reads_trimmed_reverse
                :rtufc => {rules:[/_L\d{3,3}_R1_\d{3,3}\.unpaired\.fastq\.gz/]}, #reads_trimemd_unpaired_forward_chunks
                :rturc => {rules:[/_L\d{3,3}_R2_\d{3,3}\.unpaired\.fastq\.gz/]}, #reads_trimmed_unpaired_reverse_chunks
                :rtuf => {rules:[/_R1\.unpaired\.fastq\.gz/]}, #reads_trimmed_unpaired_forward
                :rtur => {rules:[/_R2\.unpaired\.fastq\.gz/]}, #reads_trimmed_unpaired_reverse
                :rfc => {rules:[/_L\d{3,3}_R1_\d{3,3}\.fastq\.gz/]}, #reads_forward_chunks
                # elsif file=~/trimmed/ && file=~/_L\d+_R._\d+\./
                #   :trimmed_splitted
                # elsif file=~/trimmed/ 
                #   :trimmed
                :rrc => {rules:[/_L\d{3,3}_R2_\d{3,3}\.fastq\.gz/]}, #reads_reverse_chunks                
                :rf => {rules:[/_R1\.fastq\.gz/]}, #reads_forward  
                :rr => {rules:[/_R2\.fastq\.gz/]}, #reads_reverse                
                :logs => {rules:[/logs/]},
                :denovo => {rules:[/denovo/]},
                :rawdata => {rules:[/raw_data/,/rawdata/]},
                :mapquant => {rules:[/MAPQUANT/]},
                :mapquant_projects => {rules:[/MAPQUANT_Projects/]},
                :project => {rules:[/Project_/], action:Proc.new{|file_name| $1.to_sym if file_name=~/Project_(.*?)\//}},
                :sample => {rules:[/Sample_/], action:Proc.new{|file_name| $1.to_sym if file_name=~/Sample_(.*?)\//}},
                :sample_sheet => {rules:[/SampleSheet.csv/]}
    }


Like for `:project` and `:sample` the user can also associate a `Proc` to have a more complex tagging strategy.


### Converting data to RDF

After quantification with Cufflinks data can be converted into RDF and this is a simple example of it
    `biongs convert:cuff:quant_to_ttl transcripts.gtf --output=transcripts.ttl --sample=SQ_0080 --project=Naive_T0 --run=110908_H125_0119_AB01W2ABXX`

in case the user do not want to specify sample, project, run and the path of the file reflects this structure:
    `110908_H125_0119_AB01W2ABXX_DATA/Project_Naive_T0/Sample_SQ_0080`

the software can extract those information automatically, just selecting the option `--get_info_from_path`

# ForDevelopers

## HowToContribute 
1. Clone Main Repository  
       `git clone https://github.com/helios/bioruby-ngs`
   This command will create a local copy of the main repository
     
2. Install Bioinformatics Tools into the repository directory  
       `rake devenv:bio_tools`

## Wrapper
Bio-Ngs comes with a build-in wrapper to map binary software directly in BioRuby as objects. From this wrapper object is possible to create Thor task as well, with a lot of sugar.
### Wrapping a binary

We want wrap TopHat the famous tool for NGS analyses.
1. The first step is to include the Wrapping module
2. set the name of the binary to call. Note: if you avid to set the program name it would not be possible to create a thor task and/or run the program
3. add the options that the binary accepts, usually if preferred to declare all the options, discover them typing `your_program_name -h`

    module Bio
      module Ngs    
        class Tophat
          include Bio::Command::Wrapper
          
          set_program Bio::Ngs::Utils.binary("tophat/tophat")
          add_option "output-dir",:type => :string, :aliases => '-o'
          add_option "min-anchor", :type => :numeric, :aliases => '-a'
          add_option "splice-mismatches", :type => :numeric, :aliases => '-m'
          #all other options that you want to expose with the wrapping
        end #Tophat
      end #Ngs
    end #Bio

is possible to use specify in the class  
    use_aliases
if you want to give a priority to short notation or if your program has only the short notation but you want to extend the task with the long one as well.
We defined a new property for add_option called `:collapse => true` is used only with `use_aliases` and it collapse the passed parameter to the short notation. An example coming from _fastx.rb_ wrapper, _note last row_:

    module Bio
      module Ngs    
        module Fastx
          class Trim
            include Bio::Command::Wrapper
            set_program Bio::Ngs::Utils.binary("fastq_quality_trimmer")
            use_aliases
            add_option :min_size, :type=>:numeric, :default=>20, :aliases => "-l", :desc=>"Minimum length - sequences shorter than this (after trimming)
            will be discarded. Default = 0 = no minimum length."
            add_option :min_quality, :type=>:numeric, :default=>10, :aliases => "-t", :desc=>"Quality threshold - nucleotides with lower 
            quality will be trimmed (from the end of the sequence)."
            add_option :output, :type=>:string, :aliases => "-o", :desc => "FASTQ output file.", :collapse=>true
            add_option :input, :type=>:string, :aliases => "-i", :desc => "FASTQ input file.", :collapse=>true
            add_option :gzip, :type => :boolean, :aliases => "-z", :desc => "Compress output with GZIP."
            add_option :verbose, :type => :boolean, :aliases => "-v", :desc => "[-v]         = Verbose - report number of sequences.
            If [-o] is specified,  report will be printed to STDOUT.
            If [-o] is not specified (and output goes to STDOUT),
            report will be printed to STDERR."
            add_option :quality_type,  :type=>:numeric, :default => 33, :aliases => "-Q", :desc=>"Quality of fastq file"
          end
        end
      end
    end

fastq_quality_trimmer accepts only short notation options and we need to pass an input file, but for some reason popen used internally doesn't work properly with the standard behavior so using `:collapse=>true` the application will be called:

    fastq_quality_trimmer -t 20 -t 10 -Q 33 -iinput_file_name.fastq -ooutput_file_name.fastq_trim

running the program by hand form the command line using a space as separator after `-i` and  `-o` works as expected. `:collapse` is a work around for this problem.



In case you program work like git which has a main program and the `sub_programs` for each feature you can use specify the sub program name with

    set_sub_program "sub_name"

The wrapper will run the command composing:

    set_program set_sub_program options arguments

A practical example of this behavior is samtools which has multiple sub programs view, merge, sort, ....
SamTools is a particular case because in biongs we are using bio-samtools a binding with FFI and the wrapper because the merge function was too complicated for the binding or at least we do not spent enough time on it, so we make the wrapping for this functionality.

This step is very similar to define a Thor task, add_option is grabbed/inspired from Thor.
Then you can user this binary also from a bioruby script just calling:

    tophat = Bio::Ngs::Tophat.new
    tophat.params = {"mate-inner-dist"=>dist, "output-dir"=>outputdir, "num-threads"=>1, "solexa1.3-quals"=>true}

__very important__: _you can pass parameters that have a name which has been previously declared in the Tophat's class. if you want to pass not declared parameters/options please use arguments._  

    tophat.run :arguments=>[index, "#{fastqs}" ]

### Define the Task
With our new wrapper, let's define a Thor task on the fly 

    class MyTasks < Thor
      desc "tophat DIST INDEX OUTPUTDIR FASTQS", "run tophat as from command line, default 6 processors"
      Bio::Ngs::Tophat.new.thor_task(self, :tophat) do |wrapper, task, dist, index, outputdir, fastqs|
        wrapper.params = {"mate-inner-dist"=>dist, "output-dir"=>outputdir, "num-threads"=>1, "solexa1.3-quals"=>true}
        wrapper.run :arguments=>[index, "#{fastqs}" ], :separator=>"="
        #you tasks here
      end
    end

Now is you list the tasks with `thor -T` you will see the new task.

You can create a new wrapper and configure it and run it from inside a Thor's tasks, like in `biongs quality:boxplot`

    desc "boxplot FASTQ_QUALITY_STATS", "plot reads quality as boxplot"
    method_option :title, :type=>:string, :aliases =>"-t", :desc  => "Title (usually the solexa file name) - will be plotted on the graph."
    method_option :output, :type=>:string, :aliases =>"-o", :desc => "Output file name. default is input file_name with .txt."
    def boxplot(fastq_quality_stats)
      output_file = options.output || "#{fastq_quality_stats}.png"
      boxplot = Bio::Ngs::Fastx::ReadsBoxPlot.new
      boxplot.params={input:fastq_quality_stats, output:output_file}
      boxplot.run
    end

### Override the run command when the binary dosen't behave normally
    module Bio
      module Ngs    
        module Samtools
          class View
            include Bio::Command::Wrapper
            set_program Bio::Ngs::Utils.binary("samtools")
            add_option "output", :type => :string, :aliases => '-o'

            alias :original_run :run
            def run(opts = {:options=>{}, :arguments=>[], :output_file=>nil, :separator=>"="})
              opts[:arguments].insert(0,"view")
              opts[:arguments].insert(1,"-b")
              opts[:arguments].insert(2,"-o")
              original_run(opts)
            end
          end #View
        end #Samtools
      end #Ngs
    end #Bio

#### Disable binary check at load time
When a wrapping is defined BioNGS verify that the program is installed on the local system, if it is not it  thrown an warning message and the task is disabled by default. This check is made for each binary wrapped, so it could takes long the first time you load BioNGS.
To skip this check the user can define an environment variable assigning one of these terms "true yes ok 1" to BIONGS_SKIP_CHECK_BINARIES

    export BIONGS_SKIP_CHECK_BINARIES=true

you can also add this setting to the .bashrc or .profile in the user home directory.

## Features
### Iterators for output files

Example CuffDiff.  In this class is possible to define an iterator for a specific set of output files: genes, isoforms, tss_groups, cds.
To activate the iterator is just a matter of call a class method in the class definition

    class Bio::Ngs::Cufflinks::Diff
      #... all the previous definitions
      #define iterators
      add_iterator_for :genes
      add_iterator_for :isoforms
      add_iterator_for :cds
      add_iterator_for :tss_groups
    end
  
This is an example of CuffDiff, parsing `genes.fpkm_tracking` file:

    Bio::Ngs::Cufflinks::Diff.foreach_gene_tracked("path_to_cuffdiff_output_directory") do |gene_fpkm_track|
      expression_profile = (1..7).map do |sample_idx|
        gene_fpkm_track["q#{sample_idx}_FPKM"].to_f
      end
      
      #do your stuff accessing this tabular file with gene_fpkm_track["name of the field"]
    end

In this case internally CSV library has been used to parse in an easy way the file, there is a lack of performances with huge files, gaining in flexibility.

## Loading or Not tasks from outside
If in your external library or binary you define LoadBaseTasks in Bio::Ngs (as a costant) requiring `'bio-ngs'` bio-ngs's tasks will not load but only the libraries.

    module Bio
      module Ngs
        LoadBaseTasks = true
      end
    end

This is something useful if you want to develop a separate binary which uses bio-ngs librariys.
Is not yet possible to define a list of desired tasks to load.

### Notes
* It's possible to add more sugar and we are working hard on it
* aliases are not well supported at this time. ToDo

# TODO
* Write Tutorial for Wrapper & Pipes
* Write Tutorial for handling Illumina/Fastq.gz with BioNGS Bio::Ngs::Illumina::FastqGz
* Report the version of every software installed/used from bio-ngs 
* Develop fastq quality reports with RibuVis ?
* Write documentation
* DONE: Wrapper: better support for aliases and Wrapper#params
* Convert: re factor code to use ::Daemons
* DONE:misk_tasks? Extract genes/regions of interest from a bam file and create a smaller bam
* BRANCH:misk_tasks Explore possibility to user DelayedJobs
* biongs ann:ensembl:gtf:features:categorize GTF GTF categorize also by chromosome not only by BioType
* configuration file input,output, experimental design
* DONE: include fastx toolkit, download and compile
* ANSWER: how to put in background tasks that can be run in parallel? Use Parallel (see code for quality:illumina_project_stats)
* is it possible to establish a relation between input data and output data ? like fastq task_selected output/s
* add description for developers on howto include news external tool with versions.yaml
 
# ChangeLog
 * 2011.05-26: Bump to version 0.2.0 Complete support for installing fastx and possibly other downloadable tool, inside the gem 
 * 2011-05-25: Bump to version 0.1.0 Update Cufflinks toolkit 1.0.2. Added initial support to fastx tool kit (binaries not included)
 * 2011-04-08: Tasks for filtering Ensembl annotation and create classifications. (misk_tasks branch)


# Contributing to bio-ngs

Please do not hesitate to contact us:

Raoul J.P. Bonnal, <http://github.com/helios>, r -at- bioruby -dot- org
Francesco Strozzi, <http://github.com/fstrozzi>

Post issues on <https://github.com/helios/bioruby-ngs/issues>  
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* [Fork](https://github.com/helios/bioruby-ngs/fork_select) the project 
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* [Pull request](https://github.com/helios/bioruby-ngs/pull/new/master) to BioNGS
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Francesco Strozzi and Raoul J.P. Bonnal. See LICENSE.txt for
further details.

