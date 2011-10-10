require "#{File.dirname(__FILE__)}/helper"

class TestUtils < Test::Unit::TestCase
  
  def test_plugin_binary
    assert_nothing_raised do
      Bio::Ngs::Utils.binary("sff_extract")
    end
  end
  
  def test_plugin_os_binary
    assert_nothing_raised do
      Bio::Ngs::Utils.binary("samtools")
    end
  end
  
  def test_os_binary
    assert_nothing_raised do
      Bio::Ngs::Utils.binary("ruby")
    end
  end
  
  def test_raise_error
    assert_raise Bio::Ngs::Utils::BinaryNotFound do
      Bio::Ngs::Utils.binary("fake_binary")
    end
  end
  
end
