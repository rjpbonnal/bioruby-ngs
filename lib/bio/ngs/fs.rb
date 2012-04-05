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
                  end #read
                end #each
              end #write
            end #if
        end #cat
        alias :merge :cat


        def files(everything, suffix=nil)
          if everything.is_a? String
            if File.file? everything
              [File.expand_path(everything)]
            elsif File.directory? everything
                files(Dir.glob(File.join(everything, suffix.nil? ? "*" : "*"+suffix)).select{|item| File.file? item}).flatten
            elsif everything=~/\*/
              files(Dir.glob(everything)).flatten
            elsif everything=~/[ ,:;]/
             files(everything.split(/[ ,:;]/))
            end
          elsif everything.is_a? Array
            everything.map do |item|
              files(item)
            end.flatten
          end
        end
      end  #self
    end #FS
  end #Ngs
end #Bio