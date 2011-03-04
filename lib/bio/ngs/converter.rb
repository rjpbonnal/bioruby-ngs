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
      def self.qseq2fastq_pe(qseq_line)
        qseq = qseq_line.split #logic here
        qseq_out = "@#{qseq[0]}:#{qseq[2]}:#{qseq[3]}:#{qseq[4]}:#{qseq[5]}#0/#{qseq[7]}\n#{qseq[8]}\n+\n#{qseq[9].gsub(/N/,'\.')}" if qseq[10]=="1"
      end
      def self.qseq2fastq_se(qseq_line)
        qseq = qseq_line.split #logic here
        qseq_out = "@#{qseq[0]}:#{qseq[2]}:#{qseq[3]}:#{qseq[4]}:#{qseq[5]}#0/\n#{qseq[8]}\n+\n#{qseq[9].gsub(/N/,'\.')}" if qseq[10]=="1"
      end
    end #Formatter
  end #Ngs
end #Bio