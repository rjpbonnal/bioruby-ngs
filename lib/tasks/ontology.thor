class Ontology < Thor
  

  class Db < Ontology
  
    desc "init", "Initialize Ontology DB"
    def init
      if Dir.exists? "db" and Dir.exists? "conf"
        db = Bio::Ngs::Db.new :ontology
        db.create_tables
        invoke "ontology:download:go"
        invoke "ontology:load:go" ["data/gene_ontology.1_2.obo"]
      else
        puts "No db or conf directory found! Please run 'biongs project:update:annotation'"
        exit
      end
    end
    
    desc "export [TABLE]","Export the data from a table to a tab-separated file"
    method_option :fileout, :type => :string, :desc => "file used to save the output", :required => true
    def export(table)
      if Dir.exists? "db"
        db = Bio::Ngs::Db.new :ontology
        db.export(table,options[:fileout])
      else
        puts "No conf directory found! Can't load database connection information"
        exit
      end
    end
    
  end


  class Load < Ontology
    
    desc "go [FILE]", "Import GO definition file"
    def go(file)
      Bio::Ngs::Ontology.go_import file
      puts "Import completed.\n"
    end
    
    desc "genego [FILE]", "Import Gene-GO file (JSON)"
    def genego(file)
      Bio::Ngs::Ontology.load_go_genes file
      puts "Import completed"
    end
    
    
  end
  
  class Report < Ontology
    
    desc "go","Output a graphical report on the GO for the sequences annotated in the db"
    def go
      db = Bio::Ngs::Db.new :ontology
      ontologies = {}
      Gene.find(:all).each do |gene|
        gene.go.each do |ontology|
          ontologies[ontology.namespace] = Hash.new(0) unless ontologies.has_key? ontology.namespace
          ontologies[ontology.namespace][ontology.name] += 1
        end
      end
      ontologies.each_pair do |namespace,terms|
         terms = terms.sort {|a,b| b[1] <=> a[1]}
         terms.flatten!
         Bio::Ngs::Graphics.bubble_chart(namespace+"_go.svg",Hash[*terms[0..39]])
      end
    end
    
  end
  
  class Download < Ontology
    
    desc "go", "Download the GeneOntology file"
    def go
      Bio::Ngs::Utils.download_with_progress(:url => "http://www.geneontology.org/ontology/obo_format_1_2/gene_ontology.1_2.obo", :filename => "data/gene_ontology.1_2.obo")
    end
    
    desc "goslim", "Download the Uniprot GeneOntology Slim file"
    def goslim
      Bio::Ngs::Utils.download_with_progress(:url => "http://www.geneontology.org/GO_slims/goslim_goa.obo", :filename => "data/goslim_goa.obo")
    end
    
    desc "all", "Download the GO files"
    def all
      invoke :goslim
      invoke :go
    end

    
  end

end