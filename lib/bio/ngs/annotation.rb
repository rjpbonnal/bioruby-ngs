module Bio
  module Ngs
    class Annotation
      
      def self.blast_import(file,yaml_file,models=Dir.pwd+"/db/models/annotation_models.rb")
        db = Bio::Ngs::Db.new(yaml_file,models)
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
            inserts << [iter.query_def,hit.hit_id.split("|")[1],hit.hit_def,evalue,identity,positive]
            if inserts.size == 1000
              db.insert_many("blast_outputs","INSERT INTO blast_outputs(query_id,target_id,target_description,evalue,identity,positive) VALUES(?,?,?,?,?,?)",inserts)
              inserts = []
            end  
          end
        end
        db.insert_many("blast_outputs","INSERT INTO blast_outputs(query_id,target_id,target_description,evalue,identity,positive) VALUES(?,?,?,?,?,?)",inserts) if inserts.size > 0
        puts "Parising completed. All the data are now stored into the db.\n"
      end
      
      def self.goa_import(file,yaml_file,models=Dir.pwd+"/db/models/annotation_models.rb")
        db = Bio::Ngs::Db.new(yaml_file,models)
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
        puts "Import completed.\n"
      end
      
      def self.go_import(file,yaml_file,models=Dir.pwd+"/db/models/annotation_models.rb")
        db = Bio::Ngs::Db.new(yaml_file,models)
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
              db.insert_many("go","INSERT INTO go(go_id,name,namespace,is_a) VALUES(?,?,?,?)",inserts)
              inserts = []
            end
          end
        end
        db.insert_many("go","INSERT INTO go(go_id,name,namespace,is_a) VALUES(?,?,?,?)",inserts) if inserts.size > 0
        puts "Import completed.\n"
      end
      
    end
  end
end