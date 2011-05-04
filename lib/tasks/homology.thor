class Homology < Thor
    
  class Run < Homology
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
  

  class Db < Homology
  
    desc "init", "Initialize Homology DB"
    def init
      if Dir.exists? "db" and Dir.exists? "conf"
        db = Bio::Ngs::Db.new :homology
        db.create_tables
      else
        puts "No db or conf directory found! Please run 'biongs project:update:annotation'"
        exit
      end
    end
    
    desc "export [TABLE]","Export the data from a table to a tab-separated file"
    method_option :fileout, :type => :string, :desc => "file used to save the output", :required => true
    def export(table)
      if Dir.exists? "db"
        db = Bio::Ngs::Db.new :homology
        db.export(table,options[:fileout])
      else
        puts "No conf directory found! Can't load database connection information"
        exit
      end  
    end
    
  end


  class Load < Homology
    
    desc "blast [FILE]","Parse Blast XML output and load the results into Annotation DB"
    def blast(file)      
      Bio::Ngs::Homology.blast_import file
      puts "Parising completed. All the data are now stored into the db.\n"
    end
    
    desc "goa","Import GO Annotation file"
    method_option :file, :type => :string, :default => "data/goa_uniprot"
    def goannotation
      Bio::Ngs::Homology.goa_import options[:file]
      puts "Import completed.\n"
    end
    
  end
  
  class Report < Homology
    
    desc "blast","Output a graphical report on the Blast homology search"
    method_option :file, :type => :string, :desc => "Read the results from a file and not from the db"
    method_option :fileout, :type => :string, :desc => "File to write the SVG", :default => "blast_report.svg"
    def blast
      db = Bio::Ngs::Db.new :homology
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
  
  class Convert < Homology
    
    
    desc "blast [XML FILE]","Convert Blast output to tab-separated file"
    method_option :file_out, :type => :string, :required => true, :desc => "File name for report"
    def blast(file)
      Bio::Ngs::Homology.blast2text(file,options[:file_out])
    end
    
  end
  
  class Download < Homology

    desc "uniprot","Download the Uniprot-SwissProt file from UniprotKB"
    def uniprot
      Bio::Ngs::Utils.download_and_uncompress("ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz","data/uniprot_sprot.fasta.gz")
    end
    
    desc "goannotation","Download the Uniprot GeneOntology Annotation file"
    def goannotation
      Bio::Ngs::Utils.download_and_uncompress("http://cvsweb.geneontology.org/cgi-bin/cvsweb.cgi/go/gene-associations/gene_association.goa_uniprot_noiea.gz?rev=HEAD","data/goa_uniprot.gz")
    end
    
    desc "all", "Download the Uniprot and GO Annotation file"
    def all
      invoke :uniprot
      invoke :goannotation
    end
    
  end

end