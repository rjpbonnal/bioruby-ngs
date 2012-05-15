Given /^a range from "(.*?)" to "(.*?)"$/ do |start, stop|
  #pending # express the regexp above with the code you wish you had
  @range = (start.to_i..stop.to_i)
end

Then /^I want to build its index$/ do
  @gtf.build_idx.should == {:transcripts=>[801, 604, 425, 425, 857, 610, 610, 607, 607, 616, 622, 809, 1003, 821, 429, 412, 1023, 610, 607, 1003, 616, 607, 404, 404, 2973, 3219, 3420, 3219, 813, 1213, 1213, 1231, 613, 408, 408, 814, 1014, 626, 814, 408, 436, 610, 662, 1016, 816, 613, 2227, 616, 616, 616, 420, 643, 7588, 813, 814, 1014, 814, 614, 614, 3018, 2013, 814, 613, 865, 433, 433, 433, 643, 619, 3454, 3454, 2043, 1237, 628, 1225, 1023, 1243, 1023, 1225, 410, 410, 1662, 1238, 1004, 1023, 2642, 2237, 2439, 2033, 2439, 2236, 834, 2280, 2642, 821, 1832, 2236, 2439, 2236, 2439, 2033, 1629, 1225, 1427, 1225, 1225, 821, 1427, 412, 412, 611, 412, 412, 412, 414, 1678, 1629, 1630, 822, 620, 1225, 1267, 821, 426, 821, 626, 1831, 821, 629, 412, 418, 1831, 1629, 1670, 1427, 1694, 1427, 1831, 1630, 1831, 620, 1629, 1629, 1225, 1023, 1427, 1427, 1427, 822, 1225, 1225, 822, 620, 818, 817, 617, 4063, 3860, 3657, 3300, 1023], :exons=>[]}
end

Then /^save it as "(.*?)"$/ do |gtf_index_filename|
  @gtf_fn_idx = File.absolute_path File.join("spec/fixture/","#{gtf_index_filename}")
  @gtf.dump_idx
  File.exists?(@gtf_fn_idx).should == true
end

Then /^I want to extract feature number "(.*?)"$/ do |index_to_get|
	tow = <<DATA
1	Cufflinks	transcript	35245	36073	1	-	.	gene_id "CUFF.1"; transcript_id "ENST00000461467"; FPKM "0.0000000000"; frac "0.000000"; conf_lo "0.000000"; conf_hi "0.000000"; cov "0.000000"; full_read_support "no";
1	Cufflinks	exon	35245	35481	1	-	.	gene_id "CUFF.1"; transcript_id "ENST00000461467"; exon_number "1"; FPKM "0.0000000000"; frac "0.000000"; conf_lo "0.000000"; conf_hi "0.000000"; cov "0.000000";
1	Cufflinks	exon	35721	36073	1	-	.	gene_id "CUFF.1"; transcript_id "ENST00000461467"; exon_number "2"; FPKM "0.0000000000"; frac "0.000000"; conf_lo "0.000000"; conf_hi "0.000000"; cov "0.000000";
DATA

	five = <<DATA
1	Cufflinks	transcript	521369	523833	1000	-	.	gene_id "ENSG00000231709"; transcript_id "ENST00000417636"; FPKM "0.0050659782"; frac "1.000000"; conf_lo "0.000000"; conf_hi "0.116517"; cov "0.009533"; full_read_support "no";
1	Cufflinks	exon	521369	521738	1000	-	.	gene_id "ENSG00000231709"; transcript_id "ENST00000417636"; exon_number "1"; FPKM "0.0050659782"; frac "1.000000"; conf_lo "0.000000"; conf_hi "0.116517"; cov "0.009533";
1	Cufflinks	exon	522201	522335	1000	-	.	gene_id "ENSG00000231709"; transcript_id "ENST00000417636"; exon_number "2"; FPKM "0.0050659782"; frac "1.000000"; conf_lo "0.000000"; conf_hi "0.116517"; cov "0.009533";
1	Cufflinks	exon	523497	523833	1000	-	.	gene_id "ENSG00000231709"; transcript_id "ENST00000417636"; exon_number "3"; FPKM "0.0050659782"; frac "1.000000"; conf_lo "0.000000"; conf_hi "0.116517"; cov "0.009533";
DATA

    fifteen = <<DATA
1	Cufflinks	transcript	808847	808957	1	-	.	gene_id "ENSG00000221146"; transcript_id "ENST00000408219"; FPKM "0.0000000000"; frac "0.000000"; conf_lo "0.000000"; conf_hi "0.000000"; cov "0.000000"; full_read_support "no";
1	Cufflinks	exon	808847	808957	1	-	.	gene_id "ENSG00000221146"; transcript_id "ENST00000408219"; exon_number "1"; FPKM "0.0000000000"; frac "0.000000"; conf_lo "0.000000"; conf_hi "0.000000"; cov "0.000000";
DATA

	pre_defined_transcripts={"2"=>tow,"5"=>five, "15"=> fifteen}
  @gtf[index_to_get.to_i].to_s.tr('"','\"').should == pre_defined_transcripts[index_to_get]
end

Then /^I want to obtain a bed file for each position in the range$/ do
	str = @range.map do |index|
		capture(:stdout) do 
			Thor::Runner.start (["filter:cufflinks:tra_at_idx",@gtf_fn_ap,index])
		end
	end
	str.each do |file|
		FileUtils.rm(file.chop)
	end
  str.should == ["CUFF.1-ENST00000461467.bed\n", "ENSG00000240361-ENST00000492842.bed\n",
                 "ENSG00000186092-ENST00000335137.bed\n", "ENSG00000231709-ENST00000417636.bed\n",
                 "CUFF.2-ENST00000423796.bed\n", "CUFF.2-ENST00000450696.bed\n",
                 "CUFF.2-TCONS_00000124.bed\n", "CUFF.2-TCONS_00000125.bed\n",
                 "CUFF.3-TCONS_00000796.bed\n", "XLOC_000669-TCONS_00001368.bed\n"]
  end