
module Bio
  module Ngs
    module Cufflinks
      class Transcript
        Fields = %w(seqname source feature start stop score strand frame)
        Attr_to_Float = %w(FPKM frac conf_lo conf_hi cov)
        Attr_to_Integer = %w(exon_number)

        attr_reader :tra, :exons, :seqname, :source, :feature, :start, :stop, :score, :strand, :frame, :attributes
        def initialize(tra="", exons=[])
          @tra = tra #TODO fix assignments for all other variables is the user pass a line
          @seqname = nil
          @source = nil
          @feature = nil
          @start = nil
          @stop = nil
          @score = nil
          @strand = nil
          @frame = nil
          @exons = exons
          @attributes = {}
        end

        def tra=(line)
          @tra = line
          data=line.split
          @seqname = data[0]
          @source = data[1]
          @feature = data[2]
          @start = data[3].to_i
          @stop = data[4].to_i
          @score = data[5]
          @strand = data[6]
          @frame = data[7]
          data[8..-1].join(" ").split(';').each do |attribute|
            data_attr=attribute.tr('"','').split
            @attributes[data_attr[0].to_sym]= if Attr_to_Float.include? data_attr[0]
            data_attr[1].to_f
          elsif Attr_to_Integer.include? data_attr[0]
            data_attr[1].to_i
          else
            data_attr[1]
          end
        end
      end

      def multi_exons?
        exons.size > 1
      end

      def mono_exon?
        exons.size == 1
      end

      def size
        @stop-@start+1
      end


      # def method_missing(meth, *args, &block)
      #   meth_name = meth.to_s.tr("=")
      #   if Fields.include? meth_name
      #     method_define meth_name do |args|

      #     end
      #   else
      #     super # You *must* call super if you don't handle the
      #     # method, otherwise you'll mess up Ruby's method
      #     # lookup.
      #     puts "There's no method called #{m} here -- please try again."
      #   end

      def to_s
        s=tra
        exons.each do |e|
          s << e
        end
        s
      end

      def to_bed(only_exons=true)
        bed_str=""
        unless only_exons
          bed_str<<"#{seqname}\t#{start}\t#{stop}\t#{attributes[:gene_id]}_#{attributes[:transcript_id]}\n"
        end
        exons.each do |e|
          data = e.tr('";','').split
          bed_str<<"#{data[0]}\t#{data[3]}\t#{data[4]}\t#{data[9]}_#{data[11]}\n"
        end
        bed_str
      end

      def clear
        @tra=""
        @exons.clear
      end

      def brand_new_isoform?
        attributes[:gene_id]=~/CUFF\.\d+/ && attributes[:transcript_id]=~/CUFF\.\d+\.\d+/
      end

      def new_isoform?
        attributes[:gene_id]=~/CUFF\.\d+/ && attributes[:transcript_id]!~/CUFF\.\d+\.\d+/
      end

      def annotated_isoform?
        attributes[:gene_id]!~/CUFF\.\d+/ && attributes[:transcript_id]!~/CUFF\.\d+\.\d+/
      end

      def byte_length
        exons.map{|e| e.length}.sum + tra.length
      end

    end #Transcript
  end #Cufflinks
end #Ngs
end #Bio
