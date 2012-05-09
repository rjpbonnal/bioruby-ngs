Feature: Manipulate Cufflinks GTF files
  In order to extract data and informtion plus new insights from RNASeq data
  As a biologist
  I want to parse transcript.gtf file created by Cufflinks during Quantification analysis

  Scenario: biologist wants to load the Cufflinks GTF
    Given the file "transcripts.gtf" from quantification analysis
    # When 
    Then I want to parse "each_transcript"
    And copying it to stdout