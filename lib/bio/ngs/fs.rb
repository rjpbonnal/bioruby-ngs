module Bio
  module Ngs
    module FS
      # def self.included(base)
      #   base.extend(ClassMethods)
      # end
      class << self
        # Write a file 'merged' which is the concatenation of multipes fastq.gz 'files'
        # files is an array of filenames
  	    def cat(files, merged)
            if files.is_a? Array
              File.open(merged,'wb') do |fmerge|
                files.each do |fname|
                  File.open(fname,'rb:binary') do |file|
                  	while line = file.gets
                  		fmerge << line
                  	end
                  	
                    # file.each_line do |line|
                    #   fmerge.puts line
                    # end #each_line
                  end #read
                end #each
              end #write
            end #if
        end #cat
      end  #self
    end #FS
  end #Ngs
end #Bio