class Sff < Thor
  
  desc "extract [FILE]", "Run sff_extract on a SFF file"
  Bio::Ngs::SffExtract.new.thor_task(self, :extract, :file) do |wrapper, task, *arguments|
    wrapper.params = task.options
    puts wrapper.run :arguments => arguments
  end
  
end