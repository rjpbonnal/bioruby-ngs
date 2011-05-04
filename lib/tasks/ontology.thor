class Ontology < Thor
  

  class Db < Ontology
  
    desc "init", "Initialize Ontology DB"
    def init
      if Dir.exists? "db" and Dir.exists? "conf"
        db = Bio::Ngs::Db.new :ontology
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
    
    
  end
  
  class Report < Ontology
    
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
    
  end
  
  class Download < Ontology
    
    desc "goslim", "Download the GeneOntology file"
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
    
    desc "all", "Download the GO files"
    def all
      invoke :goslim
      invoke :go
    end

    
  end

end