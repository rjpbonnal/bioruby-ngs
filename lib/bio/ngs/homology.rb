module Bio
  module Ngs
    class Homology
      
      
      # Method to import a Blast XML output file into a BlastOuput table created according to ActiveRecord model
      # Params: XML Blast file, YAML file for db connection, optional ActiveRecord models file
      def self.blast_import(file,yaml_file)
        db = Bio::Ngs::Db.new :homology, yaml_file
        inserts = []
        Bio::Blast::XmlIterator.new(file).to_enum.each do |iter|
          iter.each do |hit|
            identity = 0.0
            positive = 0.0
            evalue = []
            length = 0
            hit.each do |hsp|
              identity += hsp.identity.to_f
              positive += hsp.positive.to_f
              evalue << hsp.evalue
              length += hsp.align_len
            end
            identity =  (identity / length)*100
            positive = (positive / length)*100
            evalue = evalue.inject{ |sum, el| sum + el }.to_f / evalue.size
            inserts << [iter.query_def,hit.hit_id,hit.hit_def,evalue,identity,positive]
            if inserts.size == 1000
              db.insert_many("blast_outputs","INSERT INTO blast_outputs(query_id,target_id,target_description,evalue,identity,positive) VALUES(?,?,?,?,?,?)",inserts)
              inserts = []
            end  
          end
        end
        db.insert_many("blast_outputs","INSERT INTO blast_outputs(query_id,target_id,target_description,evalue,identity,positive) VALUES(?,?,?,?,?,?)",inserts) if inserts.size > 0
      end
      
      def self.blast2text(file_in,file_out)
        out = File.open(file_out,"w")
        out.write("Query ID\tTarget ID\tTarget Description\tE-value\tIdentity\tPositive\n")
        Bio::Blast::XmlIterator.new(file_in).to_enum.each do |iter|
          iter.each do |hit|
            identity = 0.0
            positive = 0.0
            evalue = []
            length = 0
            hit.each do |hsp|
              identity += hsp.identity.to_f
              positive += hsp.positive.to_f
              evalue << hsp.evalue
              length += hsp.align_len
            end
            identity =  (identity / length)*100
            positive = (positive / length)*100
            evalue = evalue.inject{ |sum, el| sum + el }.to_f / evalue.size
            out.write([iter.query_def,hit.hit_id,hit.hit_def,evalue,identity,positive].join("\t")+"\n")
          end
        end  
      end

      
      # Method to import a GO Annotation file into GoAnnotation table created according to ActiveRecord model
      # Params: GOA file, YAML file for db connection, optional ActiveRecord models file
      def self.goa_import(file,yaml_file)
        db = Bio::Ngs::Db.new :homology, yaml_file
        inserts = []
        File.open(file).each do |line|
          next if line.start_with? "!"
          line.chomp!
          inserts << line.split("\t")
          if inserts.size == 1000
            db.insert_many("go_annotations","INSERT INTO go_annotations(db,entry_id,symbol,qualifier,go_id,db_ref,evidence,additional_identifier,aspect,name,synonym,molecule_type,taxon_id,date,assigned_by) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",inserts)
            inserts = []
          end
        end
        db.insert_many("go_annotations","INSERT INTO go_annotations(db,entry_id,symbol,qualifier,go_id,db_ref,evidence,additional_identifier,aspect,name,synonym,molecule_type,taxon_id,date,assigned_by) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",inserts) if inserts.size > 0
      end
      
    end
  end
end