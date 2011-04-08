#
#  convert.thor - Main task for converting data between NGS formats
#
# Copyright:: Copyright (C) 2011
#     Raoul J.P. Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#


module Ann #Annotation

  module Ensembl

    module Gtf

      class Transcripts  < Thor

        #source: 11      processed_transcript    exon    86612   87605   .       -       .        gene_id "ENSG00000224777"; transcript_id "ENST00000521196"; exon_number "1"; gene_name "AC069287.4"; transcript_name "AC069287.4-201";
        #output: processed_transcript ENST00000521196
        desc "class GTF", "Extract annotation from a GTF file: class of transcript"
        def class(gtf)
          begin
            File.open(gtf,'r') do |f|
              f.lines do |line|
                data = line.gsub(/"/,'').gsub(/;/,'').split
                puts "#{data[1]}\t#{data[11]}"
              end
            end
          rescue => e
            puts "Could not open file #{gtf}"
            puts e.message
          end
        end
      end #Transcripts
    end#Gtf
  end #Ensembl
end #Ann