#
#  
#
# Copyright:: Copyright (C) 2011
#     Francesco Strozzi <francesco.strozzi@gmail.com>
#     Raoul J.P. Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#

require 'ostruct'

module Bio
  module Ngs
    class FastQuality
      
      require 'matrix'
      
      attr_accessor :format
      # as reported in http://dx.doi.org/10.1093/nar/gkp1137
      # we set the default to fastq_sanger, is a better policy to specify 
      # ALWAYS the format
      def initialize(file, format=:fastq_sanger)
        begin
          @file = file
          @stream = Bio::FlatFile.auto(file)  
          @format = format
          raise ArgumentError, "the method only accepts FASTQ" unless @stream.dbclass == Bio::Fastq
        end  
      end
      
      def quality_profile
        qual = nil
        tot_reads = 0
        @stream.each do |read|
          if qual then
            qual += Vector[*read.quality_scores]
          else
            qual = Vector[*read.quality_scores]
          end
          tot_reads += 1
        end
        qual = qual/tot_reads.to_f
        return qual.to_a
      end
      
      # Restart from the beginning of the file and draw a profile of B qalities
      def track_b_count
        quals = Hash.new(0) # a new element is initialized at zero
        reads_count=0
        @stream = Bio::FlatFile.auto(@file)
        @stream.each do |read|
          read.format = format
          reads_count+=1
          read_qualities = read.quality_scores
          read_qualities.each_index do |read_index|            
            quals[read_index]+=1 if read_qualities[read_index] == 2
          end #seq
        end#reads
        OpenStruct.new(:n_reads=>reads_count, :b_profile=>quals.sort)
      end
    end #FastQuality
  end #Ngs
end #Bio