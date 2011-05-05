require 'helper'

class TestHomology < Test::Unit::TestCase 

  
  context "Database class" do
    
    should "take the db type and an optional yaml file" do
      db = Bio::Ngs::Db.new :ontology, "test/conf/test_db.yml"
      assert_equal(Bio::Ngs::Db,db.class)
    end
    
    should "raise an error if an invalid db type is called" do
      assert_raise ArgumentError do
        db = Bio::Ngs::Db.new :invalid_type
      end
    end
    
  end
  
end