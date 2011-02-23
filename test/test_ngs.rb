require 'helper'

class TestNgs < Test::Unit::TestCase
  # should "probably rename this file and start testing for real" do
  #   flunk "hey buddy, you should probably rename this file and start testing for real"
  # end
  
  def test_init
    ngs = Bio::Ngs.new
    assert_equal("", ngs.data)
  end
  
  def test_bcl2fastq
    assert_equal("xxxx",Bio::Ngs.xxx)
  end
end
