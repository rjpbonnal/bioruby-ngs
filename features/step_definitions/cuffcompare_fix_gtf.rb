
Given /^the file "(.*?)" from cufflinks comparison$/ do |arg1|
  @gtf = File.join('spec/fixture',arg1)
end

Then /^I want a file with transcripts\/exons$/ do
  str = capture(:stdout) do
    Bio::Ngs::Cufflinks::Compare.fix_gtf(@gtf)
  end
#puts str
  str.should == <<DATA
1	Cufflinks	transcript	564460	570308	.	+	.	gene_id "XLOC_000001"; transcript_id "TCONS_00000001"; exon_number "1"; gene_name "A"; oId "SQ_0080.506.2"; nearest_ref "A1"; class_code "o"; tss_id "TSS1";
1	Cufflinks	exon	564460	560000	.	+	.	gene_id "XLOC_000001"; transcript_id "TCONS_00000001"; exon_number "1"; gene_name "A"; oId "SQ_0080.506.2"; nearest_ref "A1"; class_code "o"; tss_id "TSS1";
1	Cufflinks	exon	565394	570308	.	+	.	gene_id "XLOC_000001"; transcript_id "TCONS_00000001"; exon_number "2"; gene_name "A"; oId "SQ_0080.506.2"; nearest_ref "A1"; class_code "o"; tss_id "TSS1";
1	Cufflinks	transcript	661585	663480	.	+	.	gene_id "XLOC_000002"; transcript_id "TCONS_00000307"; exon_number "1"; gene_name "B"; oId "SQ_0081.2281.1"; nearest_ref "B1"; class_code "x"; tss_id "TSS2";
1	Cufflinks	exon	661585	662500	.	+	.	gene_id "XLOC_000002"; transcript_id "TCONS_00000307"; exon_number "1"; gene_name "B"; oId "SQ_0081.2281.1"; nearest_ref "B1"; class_code "x"; tss_id "TSS2";
1	Cufflinks	exon	662920	663480	.	+	.	gene_id "XLOC_000002"; transcript_id "TCONS_00000307"; exon_number "2"; gene_name "B"; oId "SQ_0081.2281.1"; nearest_ref "B1"; class_code "x"; tss_id "TSS2";
1	Cufflinks	transcript	664039	665999	.	+	.	gene_id "XLOC_000003"; transcript_id "TCONS_00000693"; exon_number "1"; oId "SQ_0082.19.1"; class_code "u"; tss_id "TSS3";
1	Cufflinks	exon	664039	664117	.	+	.	gene_id "XLOC_000003"; transcript_id "TCONS_00000693"; exon_number "1"; oId "SQ_0082.19.1"; class_code "u"; tss_id "TSS3";
1	Cufflinks	exon	664377	665999	.	+	.	gene_id "XLOC_000003"; transcript_id "TCONS_00000693"; exon_number "2"; oId "SQ_0082.19.1"; class_code "u"; tss_id "TSS3";
1	Cufflinks	transcript	762988	794826	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000308"; exon_number "1"; gene_name "B1"; oId "SQ_0081.20.2"; nearest_ref "B1"; class_code "j"; tss_id "TSS4";
1	Cufflinks	exon	762988	763155	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000308"; exon_number "1"; gene_name "B1"; oId "SQ_0081.20.2"; nearest_ref "B1"; class_code "j"; tss_id "TSS4";
1	Cufflinks	exon	764383	764484	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000308"; exon_number "2"; gene_name "B1"; oId "SQ_0081.20.2"; nearest_ref "B1"; class_code "j"; tss_id "TSS4";
1	Cufflinks	exon	776580	783186	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000308"; exon_number "3"; gene_name "B1"; oId "SQ_0081.20.2"; nearest_ref "B1"; class_code "j"; tss_id "TSS4";
1	Cufflinks	exon	784864	786000	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000308"; exon_number "4"; gene_name "B1"; oId "SQ_0081.20.2"; nearest_ref "B1"; class_code "j"; tss_id "TSS4";
1	Cufflinks	exon	787307	787490	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000308"; exon_number "5"; gene_name "B1"; oId "SQ_0081.20.2"; nearest_ref "B1"; class_code "j"; tss_id "TSS4";
1	Cufflinks	exon	788051	788146	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000308"; exon_number "6"; gene_name "B1"; oId "SQ_0081.20.2"; nearest_ref "B1"; class_code "j"; tss_id "TSS4";
1	Cufflinks	exon	788771	794826	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000308"; exon_number "7"; gene_name "B1"; oId "SQ_0081.20.2"; nearest_ref "B1"; class_code "j"; tss_id "TSS4";
1	Cufflinks	transcript	766765	794826	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000309"; exon_number "1"; gene_name "B1"; oId "SQ_0081.20.5"; nearest_ref "B1"; class_code "j"; tss_id "TSS5";
1	Cufflinks	exon	766765	767222	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000309"; exon_number "1"; gene_name "B1"; oId "SQ_0081.20.5"; nearest_ref "B1"; class_code "j"; tss_id "TSS5";
1	Cufflinks	exon	776580	783186	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000309"; exon_number "2"; gene_name "B1"; oId "SQ_0081.20.5"; nearest_ref "B1"; class_code "j"; tss_id "TSS5";
1	Cufflinks	exon	784864	785000	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000309"; exon_number "3"; gene_name "B1"; oId "SQ_0081.20.5"; nearest_ref "B1"; class_code "j"; tss_id "TSS5";
1	Cufflinks	exon	787307	787490	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000309"; exon_number "4"; gene_name "B1"; oId "SQ_0081.20.5"; nearest_ref "B1"; class_code "j"; tss_id "TSS5";
1	Cufflinks	exon	788051	788146	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000309"; exon_number "5"; gene_name "B1"; oId "SQ_0081.20.5"; nearest_ref "B1"; class_code "j"; tss_id "TSS5";
1	Cufflinks	exon	788771	794826	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00000309"; exon_number "6"; gene_name "B1"; oId "SQ_0081.20.5"; nearest_ref "B1"; class_code "j"; tss_id "TSS5";
1	Cufflinks	transcript	782549	794826	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00001286"; exon_number "1"; gene_name "B1"; oId "SQ_0176.34.5"; nearest_ref "B1"; class_code "j"; tss_id "TSS6";
1	Cufflinks	exon	782549	783186	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00001286"; exon_number "1"; gene_name "B1"; oId "SQ_0176.34.5"; nearest_ref "B1"; class_code "j"; tss_id "TSS6";
1	Cufflinks	exon	784834	784982	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00001286"; exon_number "2"; gene_name "B1"; oId "SQ_0176.34.5"; nearest_ref "B1"; class_code "j"; tss_id "TSS6";
1	Cufflinks	exon	787327	787490	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00001286"; exon_number "3"; gene_name "B1"; oId "SQ_0176.34.5"; nearest_ref "B1"; class_code "j"; tss_id "TSS6";
1	Cufflinks	exon	788571	794826	.	+	.	gene_id "XLOC_000004"; transcript_id "TCONS_00001286"; exon_number "4"; gene_name "B1"; oId "SQ_0176.34.5"; nearest_ref "C1"; class_code "j"; tss_id "TSS6";
1	Cufflinks	transcript	895762	902095	.	+	.	gene_id "XLOC_000005"; transcript_id "TCONS_00000694"; exon_number "1"; gene_name "C"; oId "SQ_0082.8.1"; nearest_ref "C1"; class_code "j"; tss_id "TSS7";
1	Cufflinks	exon	895762	896180	.	+	.	gene_id "XLOC_000005"; transcript_id "TCONS_00000694"; exon_number "1"; gene_name "C"; oId "SQ_0082.8.1"; nearest_ref "C1"; class_code "j"; tss_id "TSS7";
1	Cufflinks	exon	896173	897130	.	+	.	gene_id "XLOC_000005"; transcript_id "TCONS_00000694"; exon_number "2"; gene_name "C"; oId "SQ_0082.8.1"; nearest_ref "C1"; class_code "j"; tss_id "TSS7";
1	Cufflinks	exon	897406	897851	.	+	.	gene_id "XLOC_000005"; transcript_id "TCONS_00000694"; exon_number "3"; gene_name "C"; oId "SQ_0082.8.1"; nearest_ref "C1"; class_code "j"; tss_id "TSS7";
1	Cufflinks	exon	878084	895297	.	+	.	gene_id "XLOC_000005"; transcript_id "TCONS_00000694"; exon_number "4"; gene_name "C"; oId "SQ_0082.8.1"; nearest_ref "C1"; class_code "j"; tss_id "TSS7";
1	Cufflinks	exon	894489	893910	.	+	.	gene_id "XLOC_000005"; transcript_id "TCONS_00000694"; exon_number "5"; gene_name "C"; oId "SQ_0082.8.1"; nearest_ref "C1"; class_code "j"; tss_id "TSS7";
1	Cufflinks	exon	910343	902095	.	+	.	gene_id "XLOC_000005"; transcript_id "TCONS_00000694"; exon_number "6"; gene_name "C"; oId "SQ_0082.8.1"; nearest_ref "C1"; class_code "j"; tss_id "TSS7";
DATA


end