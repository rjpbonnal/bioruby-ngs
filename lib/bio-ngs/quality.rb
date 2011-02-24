module Bio
  module NGS
    class FastQuality
      
      require 'matrix'
      
      attr_reader :stream
      def initialize(file)
        begin
          @stream = Bio::FlatFile.auto(file)
          raise ArgumentError, "the method only accepts FASTQ" unless @stream.dbclass == Bio::Fastq
        end  
      end
      
      def quality_profile
        qual = nil
        tot_reads = 1
        @stream.each do |read|
          if qual then
            qual += Vector[*read.quality_scores]
          else
            qual = Vector[*read.quality_scores]
          end
          tot_reads += 1
          puts qual.inspect
        end
        qual = qual/tot_reads.to_f
        return qual.to_a
      end
      
    end
  end
end