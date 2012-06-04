Feature: build a project hierarchy from an hand made analysis
In order to organize and automate many processes for an NGS dataset
analyzed by hand from other bioinformaticians
As a bioinformatician
I want to have a querable data structure which represents most of the pre cumputed data

Scenario: Explore and Build data structure
  Given A path with many projects at the first and second level
  When I build the projects structure
  Then I sould get all the projects organized in the same structure.


# Scenario: Merge multiple data structure to find common datasets
#   Given
#   When
#   Then