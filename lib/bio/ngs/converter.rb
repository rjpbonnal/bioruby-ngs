#
#  converter.rb - convert qseq format to fastq
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>,
#     Ranzani Valeria <ranzani@ingm.it>
# License:: The Ruby License
#
#


module Bio
  module Ngs
    module Converter
      class Qseq

        # Source buffer:
        # String with \n as line separator
        # File (reading)
        attr_accessor :buffer
        
        # Return each line converted in fastq, is a line is not valid
        # because is not good enough that line will return a nil
        # rember to remove the nil values if you are building an array     
        def to_fastq(type)
          if ([:pe, :se].include? type.to_sym)
            @buffer.lines do |line|
              yield (send "qseq2fastq_#{type}", line)
            end
          else
            raise "Unsupported format #{type.to_sym} for qseq"
          end
        end

        def qseq2fastq_pe(qseq_line)
          qseq = qseq_line.split #logic here
          qseq_out = "@#{qseq[0]}:#{qseq[2]}:#{qseq[3]}:#{qseq[4]}:#{qseq[5]}#0/#{qseq[7]}\n#{qseq[8]}\n+\n#{qseq[9].gsub(/N/,'\.')}" if qseq[10]=="1"
        end

        def qseq2fastq_se(qseq_line)
          qseq = qseq_line.split #logic here
          qseq_out = "@#{qseq[0]}:#{qseq[2]}:#{qseq[3]}:#{qseq[4]}:#{qseq[5]}#0/\n#{qseq[8]}\n+\n#{qseq[9].gsub(/N/,'\.')}" if qseq[10]=="1"
        end

      end #Qseq
    end #Converter
  end #Ngs
end #Bio