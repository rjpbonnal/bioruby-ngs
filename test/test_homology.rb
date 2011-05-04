require 'helper'

class TestHomology < Test::Unit::TestCase 
  
  def setup
    db = Bio::Ngs::Db.new :homology, "test/conf/test_db.yml"
    db.create_tables
  end
  
  def teardown
    FileUtils.rm "test/data/test.sqlite3" if File.exists? "test/data/test.sqlite3"
  end
  
  context "Homology database" do
    
    should "have a set of empty tables created according to models" do
      assert_equal(0,GoAnnotation.count)
      assert_equal(0,BlastOutput.count)
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
    
  end
  
  context "Homology import tasks" do
    
    should "take a GO Annotation file and store it into a go_annotations table" do
      Bio::Ngs::Homology.goa_import("test/fixture/goa_uniprot","test/conf/test_db.yml")
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
      Bio::Ngs::Homology.blast_import("test/fixture/blastoutput.xml","test/conf/test_db.yml")
      b = BlastOutput.find(:first)
      assert_equal("ENSBTAG00000025113_499_35",b.query_id)
      assert_equal("sp|Q6U7Q0|Z322A_HUMAN",b.target_id)
      assert_equal("Zinc finger protein 322A OS=Homo sapiens GN=ZNF322A PE=1 SV=2",b.target_description)
    end
    
  end
  
  
end
