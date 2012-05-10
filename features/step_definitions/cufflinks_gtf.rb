
Given /^the file "(.*?)" from quantification analysis$/ do |gtf_fn|
  # pending # express the regexp above with the code you wish you had
  @gtf_fn_ap = File.absolute_path File.join("spec/fixture/",gtf_fn)
  File.exists?(File.join("spec/fixture/",gtf_fn)).should be true
  @gtf = Bio::Ngs::Cufflinks::Gtf.new(@gtf_fn_ap)
  @gtf.should_not be nil
end

Then /^I want to print "(.*?)" on stdout$/ do |each_method|
    str=@gtf.send each_method do |transcript|
      break(transcript.to_s)
    end
  #pending # express the regexp above with the code you wish you had
  puts str
  str.should =~ //
end

Then /^I want to "(.*?)" the "(.*?)"$/ do |operation, subset|
  @gtf.send(subset).count.should == 29293
end


Given /^a list of parameters "(.*?)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I want to "(.*?)" the "(.*?)" in each subdirectory$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end