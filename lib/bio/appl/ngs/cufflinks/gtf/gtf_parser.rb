
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
                block.call(transcript, @fh.lineno)
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
            block.call(t, t.to_bed(only_exons))
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

        def build_idx
          idx = Hash.new {|h,k| h[k]=[]}
          idx[:transcripts]
          idx[:exons]
          each_transcript do |t, f_lno|
            t_idx=(f_lno-t.exons.size-2)
            idx[:transcripts] << t.byte_length
            # eidx_b = t_idx +1
            # t.exons.each_index do |ei|
            #   idx[t_idx] << eidx_b + ei
            #   idx[:exons] << eidx_b + ei
            # end
          end
          @idx = idx
        end #build_idx

        def dump_idx
          build_idx unless defined?(@idx)
          # File.open("#{source.path}.idx",'w') do |w|
          #   w.puts @idx.to_yaml
          # end
          @idx[:default_hash] = @idx.default
          @idx.default = nil
          File.open("#{source.path}.idx", "w+") do |f|
            Marshal.dump(@idx, f)
          end
          @idx.default = @idx[:default_hash]
        end #dump_idx

        def load_idx
          if File.exists?("#{source.path}.idx")
            @idx = Marshal.load(File.open("#{source.path}.idx"))
            @idx.default = @idx[:default_hash]
            # File.open("#{source.path}.idx") do |r|
            #   @idx=YAML.load_stream(r)
            # end
          end
        end # load_idx

        def index
          @idx
        end

        # start from 1
        def read_transcript(n=1)
          build_idx unless defined?(@idx)
          if n==1
            source.seek(0)
            source.read(@idx[:transcripts][0])
          elsif n==2
            source.seek(@idx[:transcripts][0])
            source.read(@idx[:transcripts][n-1])
          else
            source.seek(@idx[:transcripts][0..n-2].sum)
            source.read(@idx[:transcripts][n-1])
          end
        end

      end #GtfParser

    end #Cufflinks
  end #Ngs
end #Bio

# class Array
#   def to_ranges
#     sorted=self.sort
#     left = sorted.first
#     ranges = sorted.compact.uniq.sort.map do |e|
#       if sorted[sorted.index(e) +1] == e.succ
#         right = e.succ
#         nil # set the elements between the ranges to nil
#       else
#         range_left = left
#         left=sorted[sorted.index(e) +1]
#         range_left == e ? e : Range.new(range_left, e)
#       end
#     end
#     ranges.compact
#   end
# end
