
module Bio
  module Ngs
    module Cufflinks
      # TODO use a specific class for each block (transcript)
      module GtfParser
        attr_accessor :lazy
        require 'tempfile'
        def each_transcript(&block)
          if @blocks.nil? || @blocks.empty?
            transcript = Transcript.new
            @fh.rewind
            transcript.tra = @fh.readline
            @fh.each_line do |line|
              if line =~ /\ttranscript\t/
                block.call(transcript)
                transcript.clear
                transcript.tra = line
              else line =~ /\texon\t/
                transcript.exons << line
              end
            end
          else #lazy
            not_lazy
            blocks_to_run = @blocks
            @blocks=[]
            result=select do |transcript|
              bool_blocks = blocks_to_run.map do |b|
                b.call(transcript)
              end
              !(bool_blocks.include?(nil) || bool_blocks.include?(false))
            end
            set_lazy
            result.send(:each_transcript, &block)
          end #lazy or not?
        end

        def select(&block)
          if is_lazy?
            @blocks||=[]
            @blocks << block
            self
          else
            # Find out how to concatenate multiple selections
            file = Tempfile.new("transcripts")
            each_transcript do |transcript|
              if block.call(transcript)
                file.write transcript.to_s
              end
            end
            Gtf.new(file.path) unless file.size == 0
          end
        end #select

        def multi_exon_with_lengh_and_coverage(length, coverage)
          select do |transcript|
            transcript.multi_exons? && (transcript.size > length) && (transcript.attributes[:cov] > coverage)
          end
        end

        def multi_exons
          # mark
          select do |transcript|
            transcript.multi_exons? #transcript line and exon line
          end
        end

        def mono_exon
          # mark
          select do |transcript|
            transcript.mono_exon? #transcript line and exon line
          end
        end

        def length_gt(length)
          select do |transcript|
            transcript.size > length
          end
        end


        def brand_new_isoforms
          select do |transcript|
            transcript.brand_new_isoform?
          end
        end

        def new_isoforms
          select do |transcript|
            transcript.new_isoform?
          end
        end

        def annotated_isoforms
          select do |transcript|
            transcript.annotated_isoform?
          end
        end

        def coverage_gt(size)
          select do |transcript|
            transcript.attributes[:cov] > size
          end
        end

        def to_gff3(path=".")
          if File.exists?(File.join(path,"transcripts.gtf"))
            gffread = GffRead.new
            gffread.params = {output:"transcripts.gff3"}
            gffread.run :arguments=>["transcripts.gtf"], :separator=>''
          else
            raise ArgumentError, "transcripts.gtf doesn't exists in #{path}"
          end
        end #to_gff3

        def to_bed(only_exons=true, &block)
          each_transcript do |t|
            block.call(t.to_bed(only_exons))
          end
        end #to_bed

        def set_lazy
          @lazy=true
        end

        def is_lazy?
          @lazy
        end

        def not_lazy
          @lazy = false
        end

        def save(filename=nil)
          fn = filename || "#{@fh.path}.gtf"
          File.open(fn, 'w') do |f|
            each_transcript do |transcript|
              #change this with exporting to_s when we'll use the class Transcript object
              transcript.each do |t|
                f.write t
              end
            end
          end
        end #save

        def count
          size = 0
          each_transcript do
            size+=1
          end
          size
        end #count

      end #GtfParser

    end #Cufflinks
  end #Ngs
end #Bio
