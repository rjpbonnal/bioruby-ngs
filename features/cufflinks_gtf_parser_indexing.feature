Feature: Indexing Cufflinks GTF features
  In order to extract features quickly
  As a bioinformatician
  I want to use an index for random access

  Scenario: build a GTF index
    Given the file "transcripts.gtf" from quantification analysis
    Then I want to build its index
    And save it as "transcripts.gtf.idx"

  Scenario: extract n-th feature from a GTF
    Given the file "transcripts.gtf" from quantification analysis
    Then I want to extract feature number "2"
    And I want to extract feature number "5"
    And I want to extract feature number "15"

  Scenario: extract multiple features from a GTF
    Given the file "transcripts.gtf" from quantification analysis
    And a range from "2" to "11"
    Then I want to obtain a bed file for each position in the range


  Scenario: extract a feature from a GTF using transcript name
    Given the file "transcripts.gtf" from quantification analysis
    Then I want to extract feature named "ENST00000408219"
