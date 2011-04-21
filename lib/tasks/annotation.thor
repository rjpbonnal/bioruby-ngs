class Annotation < Thor
    
  class Run < Annotation
    desc "blastn", "Run BlastN"
    Bio::Ngs::Blast::BlastN.new.thor_task(self,:blastn) do |wrapper, task|
      wrapper.params = task.options
      puts wrapper.run :arguments => [file]
    end
    
    desc "blastx", "Run BlastX"
    Bio::Ngs::Blast::BlastX.new.thor_task(self,:blastx) do |wrapper, task|
      wrapper.params = task.options
      puts wrapper.run :arguments => [file]
    end
    
  end
  

  class Db < Annotation
  
    desc "init", "Initialize Annotation DB"
    def init
      if Dir.exists? "db" and Dir.exists? "conf"
        db = Bio::Ngs::Db.new("conf/annotation_db.yml")
        db.create_tables("db/migrate/annotation")
      else
        puts "No db or conf directory found! Please run 'biongs project:update:annotation'"
        exit
      end
    end
    
    desc "export [TABLE]","Export the data from a table to a tab-separated file"
    method_option :fileout, :type => :string, :desc => "file used to save the output", :required => true
    def export(table)
      if Dir.exists? "db"
        db = Bio::Ngs::Db.new("conf/annotation_db.yml",Dir.pwd+"/db/models/annotation_models.rb")
        db.export(table,options[:fileout])
      else
        puts "No conf directory found! Can't load database connection information"
        exit
      end  
    end
    
  end


  class Import < Annotation
    
    desc "blast [FILE]","Parse Blast XML output and load the results into Annotation DB"
    def blast(file)      
      Bio::Ngs::Annotation.blast_import(file,"conf/annotation_db.yml")
      puts "Parising completed. All the data are now stored into the db.\n"
    end
    
    desc "goa","Import GO Annotations file for Uniprot into the db"
    method_option :file, :type => :string, :default => "data/goa_uniprot"
    def goannotation
      Bio::Ngs::Annotation.goa_import(options[:file],"conf/annotation_db.yml")
      puts "Import completed.\n"
    end
    
    desc "go [FILE]", "Import GO definition file"
    def go(file)
      Bio::Ngs::Annotation.go_import(file,"conf/annotation_db.yml")
      puts "Import completed.\n"
    end
    
    
  end
  
  class Report < Annotation
    
    desc "go","Output a graphical report on the GO for the sequences annotated in the db"
    def go
      db = db_connect
      dataset = Hash.new()
      BlastOutput.find(:all).each do |bo|
        bo.go_annotations.each do |go_ann|
          if (go = go_ann.go)
            dataset[go.namespace] = Hash.new(0) unless dataset.has_key? go.namespace
            dataset[go.namespace][go.name] += 1
          end
        end
      end
      dataset.each_pair do |namespace,ontologies|
        ontologies = ontologies.sort {|a,b| b[1] <=> a[1]}
        ontologies.flatten!
        Bio::Ngs::Graphics.bubble_chart(namespace+"_go.svg",Hash[*ontologies[0..39]])
      end
    end
    
    desc "blast","Output a graphical report on the Blast homology search"
    method_option :file, :type => :string, :desc => "Read the results from a file and not from the db"
    method_option :fileout, :type => :string, :desc => "File to write the SVG", :default => "blast_report.svg"
    def blast
      db = db_connect
      evalues = []
      positive_70 = 0
      total = BlastOutput.count(:all)
      positive_70 = BlastOutput.count(:conditions => "positive >= 70")
      evalue_5 = BlastOutput.count(:conditions => "evalue <= 1e-5")
      BlastOutput.find(:all).each do |result|
        evalues << result.evalue
      end
      Bio::Ngs::Graphics.bar_charts(["Total mapped","Positive (>=70)","E-value (<=1-e5)"],[total,positive_70,evalue_5],options[:fileout])
    end
  end
  
  
  class Download < Annotation

    desc "uniprot","Download the Uniprot-SwissProt file from UniprotKB"
    def uniprot
      Bio::Ngs::Utils.download_and_uncompress("ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz","data/uniprot_sprot.fasta.gz")
    end
    
    desc "goannotation","Download the Uniprot GeneOntology Annotation file"
    def goannotation
      Bio::Ngs::Utils.download_and_uncompress("http://cvsweb.geneontology.org/cgi-bin/cvsweb.cgi/go/gene-associations/gene_association.goa_uniprot_noiea.gz?rev=HEAD","data/goa_uniprot.gz")
    end
    
    desc "goslim", "Download the Uniprot GeneOntology Slim file"
    def goslim
      puts "Downloading from http://www.geneontology.org/ontology/obo_format_1_2/gene_ontology.1_2.obo"
      Bio::Ngs::Utils.download_with_progress(:url => "http://www.geneontology.org/ontology/obo_format_1_2/gene_ontology.1_2.obo", :filename => "data/gene_ontology.1_2.obo")
      puts "\nDone."
    end
    
    desc "go", "Download the Uniprot GeneOntology Slim file"
    def go
      puts "Downloading from http://www.geneontology.org/GO_slims/goslim_goa.obo"
      Bio::Ngs::Utils.download_with_progress(:url => "http://www.geneontology.org/GO_slims/goslim_goa.obo", :filename => "data/goslim_goa.obo")
      puts "\nDone."
    end
    
    desc "all", "Download the Uniprot-Swissprot and Uniprot GO Annotation files"
    def all
      invoke :uniprot
      invoke :goa
      invoke :goslim
    end

    
  end

end