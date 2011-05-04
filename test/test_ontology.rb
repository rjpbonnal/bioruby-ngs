require 'helper'

class TestOntology < Test::Unit::TestCase 
  
  def setup
    db = Bio::Ngs::Db.new :ontology, "test/conf/test_db.yml"
    db.create_tables
  end
  
  def teardown
    FileUtils.rm "test/data/test.sqlite3" if File.exists? "test/data/test.sqlite3"
  end
  
  context "Ontology database" do
    
    should "have a set of empty tables created according to models" do
      assert_equal(0,GoCount.count)
      assert_equal(0,Go.count)
    end
    
    should "have a table go" do
      fields = Go.column_names
      assert_equal(5,fields.size)
      assert_equal(["id","go_id","name","namespace","is_a"],fields)
    end
    
  end
  
  context "Ontology import tasks" do
    
    should "take a GO OBO file and store it into go table" do
      Bio::Ngs::Ontology.go_import("test/fixture/gene_ontology.obo","test/conf/test_db.yml")
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
    
  end
  
  
end