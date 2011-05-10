#
#
# Copyright:: Copyright (C) 2011
#     Francesco Strozzi <francesco.strozzi@gmail.com>
# License:: The Ruby License
#
#

module Bio
  module Ngs
    class Ontology

      # Method to import a GO OBO file into Go table created according to ActiveRecord model
      # Params: GO OBO file, YAML file for db connection
      def self.go_import(file,yaml_file=nil)
        db = Bio::Ngs::Db.new :ontology,yaml_file
        inserts = []
        file = File.open(file)
        file.each do |line|
          if line.start_with? "[Term]"
            block = file.gets("\n\n")
            is_a = []
            data = []
            block.split("\n").each do |elem|
              if elem.start_with? "id: "
                data << elem.gsub("id: ","")
              elsif elem.start_with? "name: "
                data << elem.gsub("name: ","")
              elsif elem.start_with? "is_a"
                is_a << elem.gsub("is_a: ","").split("!").first
              elsif elem.start_with? "namespace: "
                data << elem.gsub("namespace: ","")
              end
            end
            data << is_a.join(" ")
            inserts << data
            if inserts.size == 1000
              db.insert_many(:go,"INSERT INTO go(go_id,name,namespace,is_a) VALUES(?,?,?,?)",inserts)
              inserts = []
            end
          end
        end
        db.insert_many(:go,"INSERT INTO go(go_id,name,namespace,is_a) VALUES(?,?,?,?)",inserts) if inserts.size > 0
      end   
      
      # Method to lood the Gene-GO associations from a JSON file into the Ontology db
      # Params: JSON file name, YAML file for db connection (optional)
      def self.load_go_genes(file,yaml_file=nil)
        db = Bio::Ngs::Db.new :ontology, yaml_file
        list = JSON.load File.read(file)
        ontologies = Bio::Ngs::OntologyCollection.new
        list.each_with_index do |gene,index|
          ontologies << Bio::Ngs::Ontology.new(gene["gene_id"],gene["go"],gene["library"])
        end
        ontologies.to_db(yaml_file)
      end
      
      
      attr_accessor :gene_id, :go, :library
      # Constructor for Bio::Ngs::Ontology instances
      def initialize(gene_id,go=[],library=nil)
        @gene_id = gene_id
        @go = go
        @library = library
      end
      
      # Method to store a single Bio::Ngs::Ontology object into the Ontology db
      def to_db(yaml_file=nil)
        raise RuntimeError,"You must initialize the Ontolgy db with biongs ontology:db:init" if Go.count == 0
        db = Bio::Ngs::Db.new :ontology,yaml_file
        g = Gene.create(:gene_id => @gene_id, :library => @library)
        Go.where({:go_id => @go}).all.each do |go|
          g.gene_gos.create(:go_id => go.id)
        end
      end
      
      
    end
    
    # Class to handle collection of Bio::Ngs::Ontology objects. 
    # It provides a method to store all the gene-GO associations into the Ontology db
    class OntologyCollection < Array
      
      def to_db(yaml_file=nil)
        db = Bio::Ngs::Db.new :ontology, yaml_file
        genes = []
        ontologies = []
        go = {}
        Go.find_by_sql("SELECT id, go_id FROM go").each {|g| go[g.go_id] = g.id}
        self.each_with_index do |gene,index|
          raise ArgumentError "OntologyCollection can store only Bio::Ngs::Ontology objects!" if gene.class != Bio::Ngs::Ontology
          genes << [index+1,gene.gene_id,gene.library]
          gene.go.each {|o| ontologies << [index+1,go[o]] if go[o]}
        end
        db.insert_many(:genes,"INSERT INTO genes(id,gene_id,library) VALUES(?,?,?)",genes)
        db.insert_many(:gene_gos,"INSERT INTO gene_gos(gene_id,go_id) VALUES(?,?)",ontologies)        
      end
      
    end
    
    
  end
end