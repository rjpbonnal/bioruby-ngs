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
        attr_reader :type
        attr_reader :stats #keep statistics about total reads, passed filter or not.

        def initialize(default_type=nil)
          @type=default_type if [:pe, :se].include?(default_type)
          @stats = {}
        end

        def type=(data)
          if [:pe, :se].include?(data)
            @type = data
          else
            @type = nil
          end
        end

        # Return each line converted in fastq, is a line is not valid
        # because is not good enough that line will return a nil
        # rember to remove the nil values if you are building an array    
        # TODO: benchmark the performances, I suspect this is not ooptimized 
        def to_fastq(stats=false)
          if (type.nil?)            
            raise "Type of qseq not specifed."
          else
            total = 0
            passed = 0
            rejected = 0
            bases_passed_b_quality = 0
            bases_rejected_b_quality = 0
            bases_passed_total = 0
            bases_rejected_total  = 0
            bases_passed_N = 0
            bases_rejected_N = 0
            @buffer.lines do |line|
              qseq_line_array = line.split
              read  = (send "qseq2fastq_#{type}", qseq_line_array)
              total += 1
              if read
                passed+=1
                bases_passed_b_quality += qseq_line_array[9].scan("B").size
                bases_passed_N += qseq_line_array[9].scan("N").size
                bases_passed_total += qseq_line_array[9].size                
              else
                rejected+=1
                bases_rejected_b_quality += qseq_line_array[9].scan("B").size
                bases_rejected_N += qseq_line_array[9].scan("N").size
                bases_rejected_total += qseq_line_array[9].size
              end
              yield read
            end
            @stats={:reads_total=>total,
              :reads_passed=>passed,
              :reads_rejected=>rejected,
              :bases_passed_total => bases_passed_total,
              :bases_rejected_total => bases_rejected_total,
              :bases_passed_with_b_quality => bases_passed_b_quality,
              :bases_rejected_with_b_quality => bases_rejected_b_quality,
              :bases_passed_with_n => bases_passed_N,
              :bases_rejected_with_n => bases_rejected_N}
            end
          end

          # Return the reads in fastq from a paired-end read dataset
          # qseq_line is an Array  of strings generated from raw line of qseq file.
          def qseq2fastq_pe(qseq)
            #          qseq = qseq_line.split #logic here
            "@#{qseq[0]}:#{qseq[2]}:#{qseq[3]}:#{qseq[4]}:#{qseq[5]}#0/#{qseq[7]}\n#{qseq[8].gsub(/\./,'N')}\n+\n#{qseq[9]}" if qseq[10]=="1"
          end

          # Return the reads in fastq from a single read dataset
          # qseq_line is an Array  of strings generated from raw line of qseq file.
          def qseq2fastq_se(qseq)
            #         qseq = qseq_line.split #logic here
            "@#{qseq[0]}:#{qseq[2]}:#{qseq[3]}:#{qseq[4]}:#{qseq[5]}#0/\n#{qseq[8].gsub(/\./,'N')}\n+\n#{qseq[9]}" if qseq[10]=="1"
          end

        end #Qseq
      end #Converter
    end #Ngs
  end #Bio