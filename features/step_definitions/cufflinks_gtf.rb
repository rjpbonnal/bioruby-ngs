Given /^the file "(.*?)" from quantification analysis$/ do |gtf_fn|
  # pending # express the regexp above with the code you wish you had
  @gtf_fn_ap = File.absolute_path File.join("spec/fixture/",gtf_fn)
  File.exists?(File.join("spec/fixture/",gtf_fn)).should be true
end

Then /^I want to parse "(.*?)"$/ do |arg1|
	@gtf = Bio::Ngs::Cufflinks::Gtf.new(@gtf_fn_ap)
    @gtf	
  #pending # express the regexp above with the code you wish you had
end

Then /^copying it to the stdout$/ do
	false
  #pending # express the regexp above with the code you wish you had
end
