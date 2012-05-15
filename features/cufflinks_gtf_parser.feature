Feature: Manipulate Cufflinks GTF files
  In order to extract data and informtion plus new insights from RNASeq data
  As a bioinformatician
  I want to parse transcript.gtf file created by Cufflinks after Quantification analysis

  Scenario: iterating over Cufflinks GTF transcripts
    Given the file "transcripts.gtf" from quantification analysis
    Then I want to print "each_transcript" on stdout

  Scenario: count new isoforms
    Given the file "transcripts.gtf" from quantification analysis
    Then I want to "count" the "brand_new_isoforms"

  Scenario: counts new isoforms for many quantifications
    Given a list of parameters "-b -m -l 200 -c 3.0 -x -d"
    Then I want to "count" the "brand_new_isoforms" in each subdirectory


  Scenario: Save each transcript in single files
    Given the file "transcripts.gtf" from quantification analysis
    And a list of parameters "-b -m -l 200 -c 3.0"
    Then I want to save "each_trasncript" in single files formatted in "bed" format