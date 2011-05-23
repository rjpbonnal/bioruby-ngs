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
    
    should "have a set of empty tables created according to migrations" do
      assert_equal(0,Gene.count)
      assert_equal(0,Go.count)
      assert_equal(0,GeneGo.count)
    end
    
    should "have a table go" do
      fields = Go.column_names
      assert_equal(5,fields.size)
      assert_equal(["id","go_id","name","namespace","is_a"],fields)
    end
    
  end
  
  context "Ontology import tasks" do
    
    should "take a GO OBO file and store it into go table" do
      Bio::Ngs::Ontology.go_import("test/data/goslim_goa.obo","test/conf/test_db.yml")
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
  
  
  context "Bio::Ngs::Ontology" do
    
    should "store into the db the GO terms associated to Genes" do
      Bio::Ngs::Ontology.go_import("test/data/goslim_goa.obo","test/conf/test_db.yml")
      Bio::Ngs::Ontology.load_go_genes("test/data/gene-GO.json","test/conf/test_db.yml")

      db = Bio::Ngs::Db.new :ontology, "test/conf/test_db.yml"
      assert_equal(2,Gene.count)
      assert_equal(14,GeneGo.count)
      ontology = %w(GO:0005622 GO:0005634 GO:0005654 GO:0005737 GO:0007049 GO:0007059 GO:0043234)
      terms = Gene.find(1).go.map {|g| g.go_id}
      assert_equal(ontology,terms.sort)
      ontology = %w(GO:0005634 GO:0005654 GO:0005737 GO:0007049 GO:0008283 GO:0043234 GO:0051276)
      terms = Gene.find(2).go.map {|g| g.go_id}
      assert_equal(ontology,terms.sort)
      
      assert_equal("BRCA1",Gene.find(1).library)
      assert_equal("BRCA2",Gene.find(2).library)
      
    end
    
  end
  
  
end