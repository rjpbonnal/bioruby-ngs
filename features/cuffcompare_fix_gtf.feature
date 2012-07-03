Feature: Manipulate Cuffcompare GTF files
  In order to extract data and informtion plus new insights from RNASeq data
  As a bioinformatician
  I want to parse cuffcompare.combined.gtf file created by Cuffcompare

  Scenario:  fix gtf produced by cuffcompare adding transcripts
    Given the file "cuffcompare.combined.gtf" from cufflinks comparison
    Then I want a file with transcripts/exons
