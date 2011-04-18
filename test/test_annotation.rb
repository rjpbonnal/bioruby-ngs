require 'helper'

class TestAnnotation < Test::Unit::TestCase 
  
  def setup
    FileUtils.cp("lib/templates/annotation/annotation_models.tt","test/data/annotation_models.rb")
    FileUtils.mkdir "test/data/migrate" unless Dir.exists? "test/data/migrate"
    Dir.glob("lib/templates/annotation/create_*.tt").each_with_index do |migration,index|
      file = migration.split("/")[-1]
      FileUtils.cp(migration,"test/data/migrate/"+"#{Time.now.strftime("%Y%m%d%M0#{index}")}_"+file.gsub(/.tt/,'.rb'))
    end
    db = Bio::Ngs::Db.new("test/conf/test_annotation.yml",Dir.pwd+"/test/data/annotation_models.rb")
    db.create_tables("test/data/migrate")
  end
  
  def teardown
    FileUtils.rm "test/data/test_annotation.sqlite3" if File.exists? "test/data/test_annotation.sqlite3"
    FileUtils.rm "test/data/annotation_models.rb" if File.exists? "test/data/annotation_models.rb"
    Dir.glob("test/data/migrate/*").each do |file|
      FileUtils.rm file
    end
  end
  
  context "Annotation database" do
    
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
  
  context "Annotation import tasks" do
    
    should "take a GO OBO file and store it into go table" do
      Bio::Ngs::Annotation.go_import("test/fixture/gene_ontology.obo","test/conf/test_annotation.yml",Dir.pwd+"/test/data/annotation_models.rb")
      r = Go.find(:first)
      assert_equal("GO:0000003",r.go_id)
      assert_equal("reproduction",r.name)
      assert_equal("biological_process",r.namespace)
      assert_equal("GO:0008150 ",r.is_a)
      go = Go.find(:all)
      assert_equal("GO:0071941",go[-1].go_id)
      assert_equal("nitrogen cycle metabolic process",go[-1].name)
      assert_equal("biological_process",go[-1].namespace)
      total = Go.count
      assert_equal(106,total)
    end
    
    
    should "take a GO Annotation file and store it into a go_annotations table" do
      Bio::Ngs::Annotation.goa_import("test/fixture/goa_uniprot","test/conf/test_annotation.yml",Dir.pwd+"/test/data/annotation_models.rb")
      goa = GoAnnotation.find(:first)
      assert_equal("UniProtKB",goa.db)
      assert_equal("A0A8M2",goa.entry_id)
      assert_equal("lsm14a-a",goa.symbol)
      assert_equal("",goa.qualifier)
      assert_equal("GO:0003723",goa.go_id)
      assert_equal("Protein LSM14 homolog A-A",goa.name)
      assert_equal("L14AA_XENLA|lsm14a|lsm14a-a|rap55a-a|Q68F15",goa.synonym)
      assert_equal(26,GoAnnotation.count)
      goa = GoAnnotation.find(:all)
      assert_equal("A0EJE5",goa[-1].entry_id)
      assert_equal("GO:0005834",goa[-1].go_id)
    end
    
    should "take a Blast XML file and store the results into a blast_outputs table" do
      Bio::Ngs::Annotation.blast_import("test/fixture/blastoutput.xml","test/conf/test_annotation.yml",Dir.pwd+"/test/data/annotation_models.rb")
      b = BlastOutput.find(:first)
      assert_equal("ENSBTAG00000025113_499_35",b.query_id)
      assert_equal("Q6U7Q0",b.target_id)
      assert_equal("Zinc finger protein 322A OS=Homo sapiens GN=ZNF322A PE=1 SV=2",b.target_description)
    end
    
  end
  
  
end
