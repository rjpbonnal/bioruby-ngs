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
      # Params: GO OBO file, YAML file for db connection, optional ActiveRecord models file
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
      
      def self.load_go_genes(file,yaml_file=nil)
        db = Bio::Ngs::Db.new :ontology,yaml_file
        list = JSON.load File.read(file)
        list.each do |gene|
          ontology = Bio::Ngs::Ontology.new(gene["gene_id"])
          ontology.go = gene["go"]
          ontology.library = gene["library"]
        end
      end
      
      
      attr_accessor :gene_id, :go, :library
      
      def initialize(gene_id)
        @gene_id = gene_id
        @go = []
        @library = nil
      end
      
      def to_db(yaml_file=nil)
        raise RuntimeError,"You must initialize the Ontolgy db with biongs:ontology:init" if Go.count == 0
        db = Bio::Ngs::Db.new :ontology,yaml_file
        g = Gene.create(:gene_id => @gene_id, :library => @library)
        Go.where({:go_id => @go}).all.each do |go|
          g.gene_gos.create(:go_id => go.id)
        end
      end
      
      
    end
  end
end