#
#  convert.thor - Main task for converting data between NGS formats
#
# Copyright:: Copyright (C) 2011
#     Raoul J.P. Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#
require 'tempfile'
require 'json'

module Ann #Annotation
  module Ensembl
    module Gtf
      class Features < Thor
        #source: 11      processed_transcript    exon    86612   87605   .       -       .        gene_id "ENSG00000224777"; transcript_id "ENST00000521196"; exon_number "1"; gene_name "AC069287.4"; transcript_name "AC069287.4-201";
        #output: processed_transcript ENST00000521196
        desc "categorize GTF", "Extract annotation from a GTF file: class of transcript (biotype) and create a json file"
        def categorize(gtf)
          feature_idx  = 1
          transcript_id_idx = 11
          gene_id_idx = 9
          transcripts_categories = {}
          genes_categories = {}
          begin
            File.open(gtf,'r') do |f|
              f.lines do |line|
                data = line.gsub(/"/,'').gsub(/;/,'').split
                category = data[feature_idx].to_sym
                transcript_id = data[transcript_id_idx]
                gene_id = data[gene_id_idx]
                transcripts_categories[transcript_id]=category
                genes_categories[gene_id]=category
              end
            end
            # File.open(output, 'w') do |f|
            #   data_strings.each_pair do | transcript_id, category|
            #     f.puts "#{transcript_id}\t#{category}"
            #   end
            # end
            gtf_json = gtf.gsub(File.extname(gtf),'')
            File.open("#{gtf_json}_genes.json", 'w') do |f|
                f.puts genes_categories.to_json
            end
            
            File.open("#{gtf_json}_transcripts.json", 'w') do |f|
                f.puts genes_categories.to_json
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
        desc "count_cat GTF TRANSCRIPTLIST", "Count the number of transcipts in TRANSCRIPTLIST which fall into the categories defined by TRANSCRIPTSCTEGORIES."
        def count_cat_transcript(gtf, list)
          
          gtf_json = gtf.gsub(File.extname(gtf),'')+"_transcripts.json"
          
          if File.exists?(gtf_json)
            gtf_data = File.read("gtf_json")
          else
            invoke :categorize, [gtf]
            gtf_data = File.read("gtf_json")
          end
          
          ### TODO CONtinuare con la lettura dei json e accedere alla struttura dati
          cat_data = Hash.new
          category_counter = Hash.new{|hash, key| hash[key] = 0;}
          begin
            File.open(cat, 'r') do |f|
              f.lines do |line|
                data = line.split #transcript\tcategory
                cat_data[data[0]] = data[1]
                category_counter[data[1]]
              end
            end
            File.open(list, 'r') do |f|
              f.lines do |line|
                line.chop!
                category_counter[cat_data[line]]+=1
              end
            end
            puts "category\ttranscript_number"
            category_counter.sort.each do |item|
              category = item[0]
              number = item[1]
              puts "#{category}\t#{number}"
            end

            #            puts category_counter.inspect
          rescue Exception => e
            puts "Could not open file"
            puts e.message            
          end                    
        end #count_cat

        #TRANSCRIPTFPKM is the file generated from cufflinks' quantification
        #ToDo: input a cufflink output
        desc "count_transcript_fpkm TRANSCRIPTSCATEGORIES TRANSCRIPTFPKM THRESHOLD", "count the number of transcript which fall into the categoryes, filtering the original transcripts by their fpkm (cufflink quantification)"
        def count_transcript_fpkm(cat, trans_fpkm, threshold )
          begin
            temp=Tempfile.new("trans_fpkm")
            File.open(trans_fpkm,'r') do |f|
              f.readline              
              f.each do |line|
                data=line.split #data is transcript_id, value float
                #TODO: sarà giusto questo threshold magari mette un'opzione se stretto > oppure >=
                if data[1].to_f > threshold.to_f
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

module  Quant
  module MuiltiExp
    class Filter < Thor
      #biongs quant:muilti_exp:filter:aggregate CD4_Naive_Sample,CD4_Th1_Sample,CD4_Th2_Sample,CD4_Th17_Sample,CD4_Treg_Sample,CD4_Naive_Activated_Sample,CD4_Tfh_Sample 4,4,4,4,4,4,2 TestExprazioThr --threshold 9.99
      desc "aggregate POPULATIONS SIZES OUTPUTPREFIX", "Aggregate the populations"
      method_option :threshold, :type => :numeric, :desc => "reset the values to NAN with a value below the threshold"
      def aggregate(populations, sizes, outputprefix)
        pops = populations.split(',')
        pops_sizes = sizes.split(',').map{|n| n.to_i}

        if pops.size == pops_sizes.size
          names = Hash.new
          pops.each_index do |index|
            names[pops[index]]=pops_sizes[index]
          end
          default_path = "quantification/transcripts_FPKM.expr"
          thr = options.threshold
          
          table ={:header=>[], :data=>Hash.new{|hash, key| hash[key] = Array.new;}}
          names.each_pair do |name, n_samples|
            n_samples.times do |n|
              sample_name = "#{name}#{n+1}"
              table[:header]<<sample_name
              file_name = File.join(sample_name, default_path)
              File.open(file_name,'r') do |f| 
                f.lines do |l|
                  d = l.split
                  transcript = d[0].to_sym
                  fpkm = thr.nil? ? d[1].to_f : (d[1].to_f > thr ? d[1].to_f : "NA")
                  table[:data][transcript] << fpkm
                end #lines
              end  #file read
            end #times
          end #names
          File.open("quantification_fpkms_filter_#{outputprefix}.csv", 'w') do |f|
            f.puts table[:header].join("\t")
            check_size = table[:header].size
            table[:data].each_pair do |transcript, fpkms|
              remove = fpkms.select{|item| item=="NA"}.size==check_size
              f.puts transcript.to_s+"\t"+fpkms.join("\t") unless remove
            end #table
          end #write
        else
          raise "The length of the parameters must be the same"
        end
      end #aggregate        




    end #Fileter
  end #MultiExp
end #Quant