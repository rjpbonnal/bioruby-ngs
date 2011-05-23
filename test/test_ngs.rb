require 'helper'

class TestNgs < Test::Unit::TestCase
  # should "probably rename this file and start testing for real" do
  #   flunk "hey buddy, you should probably rename this file and start testing for real"
  # end

  def setup
    @qseq_str="HWI-BRUNOP16X   0001    8       1       15744   1220    0       1       GNAGCCGATCCACCTCCCAGCCTTCCTGGGATACAAGTCTGGCATGACTC      TBTTTTTTTT`^``Sdbd_deeeeeeeeeeeWUdd_bbbfdTedXOTTTS      1"
  end
  
  def test_qseq2fastq_pe
    #qseq_pe_output="@HWI-BRUNOP16X:8:1:15744:1220#0/1\nGNAGCCGATCCACCTCCCAGCCTTCCTGGGATACAAGTCTGGCATGACTC\n+\nTBTTTTTTTT`^``Sdbd_deeeeeeeeeeeWUdd_bbbfdTedXOTTTS"    
    #assert_equal(qseq_pe_output, Bio::Ngs::Converter.qseq2fastq_pe(@qseq_str))
  end

  def test_qseq2fastq_se
    #qseq_se_output="@HWI-BRUNOP16X:8:1:15744:1220#0/\nGNAGCCGATCCACCTCCCAGCCTTCCTGGGATACAAGTCTGGCATGACTC\n+\nTBTTTTTTTT`^``Sdbd_deeeeeeeeeeeWUdd_bbbfdTedXOTTTS"    
    #assert_equal(qseq_se_output, Bio::Ngs::Converter.qseq2fastq_se(@qseq_str))
  end
end
