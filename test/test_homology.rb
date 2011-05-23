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
    
    should "have a set of empty tables created according to migrations" do
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
      Bio::Ngs::Homology.goa_import("test/data/goa_uniprot","test/conf/test_db.yml")
      goa = GoAnnotation.find(:first)
      assert_equal("UniProtKB",goa.db)
      assert_equal("Q5TM25",goa.entry_id)
      assert_equal("AIF1",goa.symbol)
      assert_equal("colocalizes_with",goa.qualifier)
      assert_equal("GO:0032587",goa.go_id)
      assert_equal("Allograft inflammatory factor 1",goa.name)
      assert_equal("AIF1_MACMU|AIF1",goa.synonym)
      assert_equal(27,GoAnnotation.count)
      goa = GoAnnotation.find(:all)
      assert_equal("Q5U241",goa[-1].entry_id)
      assert_equal("GO:0008285",goa[-1].go_id)
    end
    
    should "take a Blast XML file and store the results into a blast_outputs table" do
      Bio::Ngs::Homology.blast_import("test/data/blastoutput.xml","test/conf/test_db.yml")
      b = BlastOutput.find(:first)
      assert_equal("ENSBTAG00000031386_1906_35",b.query_id)
      assert_equal("Q5TTP0",b.target_id)
      assert_equal("WD repeat-containing protein on Y chromosome OS=Anopheles gambiae GN=WDY PE=4 SV=4",b.target_description)
      assert_equal(2.55108e-57,b.evalue)
      assert_equal(29.50530035335689,b.identity)
      assert_equal(47.879858657243815,b.positive)
    end
    
  end
  
  context "Homology convert tasks" do
    
    should "create a tab-separated file starting from the Blast XML file" do
      Bio::Ngs::Homology.blast2text("test/data/blastoutput.xml","test/data/blastoutput.txt")
      f = File.read("test/data/blastoutput.txt")
      header,record = f.split("\n")
      assert_equal("Query ID\tTarget ID\tTarget Description\tE-value\tIdentity\tPositive",header)
      elements = record.split("\t")
      assert_equal("ENSBTAG00000031386_1906_35",elements[0])
      assert_equal("sp|Q5TTP0|WDY_ANOGA",elements[1])
      assert_equal("WD repeat-containing protein on Y chromosome OS=Anopheles gambiae GN=WDY PE=4 SV=4",elements[2])
      assert_equal("2.55108e-57",elements[3])
      assert_equal("29.50530035335689",elements[4])
      assert_equal("47.879858657243815",elements[5])
      FileUtils.rm "test/data/blastoutput.txt"
    end
    
    should "create a JSON file with the GO Annotation present into the db" do
      Bio::Ngs::Homology.goa_import("test/data/goa_uniprot","test/conf/test_db.yml")
      Bio::Ngs::Homology.blast_import("test/data/blastoutput.xml","test/conf/test_db.yml")
      Bio::Ngs::Homology.go_annotation_to_json("test/data/go_annotations.json","test","test/conf/test_db.yml")
      data = JSON.parse File.read("test/data/go_annotations.json")
      assert_equal(1,data.size)
      data = data.first
      assert_equal("ENSBTAG00000031386_1906_35",data["gene_id"])
      assert_equal(3,data["go"].size)
      assert_equal("GO:0003674",data["go"][0])
      assert_equal("GO:0005575",data["go"][1])
      assert_equal("GO:0008150",data["go"][2])
      assert_equal("test",data["library"])
      FileUtils.rm "test/data/go_annotations.json"
    end
    
  end
  
  
end
