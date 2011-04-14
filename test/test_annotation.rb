require 'helper'

class TestAnnotation < Test::Unit::TestCase
  
  context "Annotation database" do
    
    setup do
      FileUtils.cp("lib/templates/annotation/annotation_models.tt","test/data/annotation_models.rb")
      FileUtils.mkdir "test/data/migrate" unless Dir.exists? "test/data/migrate"
      Dir.glob("lib/templates/annotation/create_*.tt").each_with_index do |migration,index|
        file = migration.split("/")[-1]
        FileUtils.cp(migration,"test/data/migrate/"+"#{Time.now.strftime("%Y%m%d%M0#{index}")}_"+file.gsub(/.tt/,'.rb'))
      end
      db = Bio::Ngs::Db.new("test/conf/test_annotation.yml",Dir.pwd+"/test/data/annotation_models.rb")
      db.create_tables("test/data/migrate")
    end
    
    teardown do
      FileUtils.rm "test/data/test_annotation.sqlite3" if File.exists? "test/data/test_annotation.sqlite3"
      FileUtils.rm "test/data/annotation_models.rb"
      Dir.glob("test/data/migrate/*").each do |file|
        FileUtils.rm file
      end
    end
    
    should "have a set of empty tables created according to models" do
      assert_equal(0,GoAnnotation.count)
      assert_equal(0,BlastOutput.count)
      assert_equal(0,Go.count)
    end
    
    should "have a table blast_outputs" do
      fields = BlastOutput.column_names
      assert_equal(7,fields.size)
      assert_equal(["id","query_id","target_id","target_description","evalue","identity","positive"],fields)
    end
    
    should "have a table go_annotations" do
      fields = GoAnnotation.column_names
      assert_equal(16,fields.size)
      assert_equal(["id","db","entry_id","symbol","qualifier","go_id","db_ref","evidence","additional_identifier","aspect","name","synonym","molecule_type","taxon_id","date","assigned_by"],fields)      
    end
    
    should "have a table go" do
      fields = Go.column_names
      assert_equal(5,fields.size)
      assert_equal(["id","go_id","name","namespace","is_a"],fields)
    end
    
  end
  
  
end
