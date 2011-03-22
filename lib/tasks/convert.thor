
require File.expand_path(File.dirname(__FILE__) + '/../bio/ngs/utils')
require File.expand_path(File.dirname(__FILE__) + '/../wrapper')
require File.expand_path(File.dirname(__FILE__) + '/../bio/appl/ngs/')

#module Converter
  class BclToQseq< Thor

    # argument :basecall, :type => :string, :desc => "The base calling directory"
    #     argument :output, :type => :string, :desc => "Output directory"
    #     argument :jobs, :type => :numeric, :desc => "Number of precessor to use for conversion"
    
    desc "bcl2qseq BASECALLS OUTPUTDIR ", "Convert a bcl dataset in qseq"
    Bio::Ngs::Bclqseq.new.thor_task(self, :bclq2seq) do |wrapper, task, output|
      #wrapper.params = task.options
      #wrapper.run :arguments=>[text, who] 
      #you tasks here
      puts basecall
      puts outout
      puts jobs
      puts task.options.inspect
    end #task
  end# BclToQseq
#end #Convert
