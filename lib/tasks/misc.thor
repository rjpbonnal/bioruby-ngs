#
#  convert.thor - Main task for converting data between NGS formats
#
# Copyright:: Copyright (C) 2011
#     Raoul J.P. Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#
require 'tempfile'

module Ann #Annotation
  module Ensembl
    module Gtf
      class Trans < Thor
        #source: 11      processed_transcript    exon    86612   87605   .       -       .        gene_id "ENSG00000224777"; transcript_id "ENST00000521196"; exon_number "1"; gene_name "AC069287.4"; transcript_name "AC069287.4-201";
        #output: processed_transcript ENST00000521196
        desc "cat GTF OUTPUT", "Extract annotation from a GTF file: class of transcript"
        def cat(gtf, output)
          data_strings = {} 
          begin
            File.open(gtf,'r') do |f|
              f.lines do |line|
                data = line.gsub(/"/,'').gsub(/;/,'').split
                category = data[1]
                transcript_id = data[11]
                data_strings[transcript_id]=category
              end
            end
            File.open(output, 'w') do |f|
              data_strings.each_pair do | transcript_id, category|
                f.puts "#{transcript_id}\t#{category}"
              end
            end
          rescue Exception => e
            puts "Could not open file #{gtf}"
            puts e.message
          end
        end

        #Note: TRANSCRIPTSCATEGORIES can be generated calling the task cat (above)
        # OUTPUT on STDOUT
        # category        transcript_number
        # pseudogene      2
        # processed_transcript    26
        # protein_coding  313
        # snRNA   1
        # lincRNA 6
        # scRNA_pseudogene        1
        # miRNA   1        
        desc "count_cat TRANSCRIPTSCATEGORIES TRANSCRIPTLIST", "Count the number of transcipts in TRANSCRIPTLIST which fall into the categories defined by TRANSCRIPTSCTEGORIES."
        def count_cat(cat, list)
          cat_data = Hash.new
          begin
            File.open(cat, 'r') do |f|
              f.lines do |line|
                data = line.split #transcript\tcategory
                cat_data[data[0]] = data[1]
              end
            end
            category_counter = Hash.new{|hash, key| hash[key] = 0;}
            File.open(list, 'r') do |f|
              f.lines do |line|
                line.chop!
                category_counter[cat_data[line]]+=1
              end
            end
            puts "category\ttranscript_number"
            category_counter.each_pair do |category, number|
              puts "#{category}\t#{number}"
            end

            #            puts category_counter.inspect
          rescue Exception => e
            puts "Could not open file"
            puts e.message            
          end                    
        end #count_cat

        #TRANSCRIPTFPKM is the file generated from cufflinks' quantification
        desc "count_transcript_fpkm TRANSCRIPTSCATEGORIES TRANSCRIPTFPKM THRESHOLD", "count the number of transcript which fall into the categoryes, filtering the original transcripts by their fpkm (cufflink quantification)"
        def count_transcript_fpkm(cat, trans_fpkm, threshold )
          begin
            temp=Tempfile.new("trans_fpkm")
            File.open(trans_fpkm,'r') do |f|
              f.readline              
              f.each do |line|
                data=line.split #data is transcript_id, value float
                if data[1].to_f >= threshold.to_f
                  temp.puts data[0]
                end
              end              
            end            
            temp.flush
            invoke :count_cat, [cat, temp.path]

            temp.close
          rescue Exception => e
            puts "Could not open file"
            puts e.message                        
          end
        end #count_transcript_fpkm
      end #Transcripts
    end#Gtf
  end #Ensembl
end #Ann