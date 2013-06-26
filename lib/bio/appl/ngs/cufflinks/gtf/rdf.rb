module Bio
  module Ngs
    module Cufflinks
      class Gtf
        module RDF
          require 'securerandom'

#user domain to specify what is it
#user entity to define the name
          def uri(opts={})
            if !opts.empty?
              return "<http://genome.db/#{opts[:domain]}/#{opts[:entity]}>"
            else
              return "gtf:uuid-#{SecureRandom.uuid}"
            end
          end

          def triple(s, p, o)
            #return [s, p, o].join("\t") + " ."
            puts [s, p, o].join("\t") + " ."
          end

          def quote(str)
            return "\"#{str}\""
          end

          def prefix
            return [
              "@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .",
              "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .",
              "@prefix ns0: <http://purl.obolibrary.org/obo/> .",
              "@prefix gtf: <http://genome.db/gtf/> .",
              "@prefix gtf_vocabulary: <http://genome.db/gtf/rdf-schema#> .",
              "@prefix ngs: <http://genome.db/ngs/> .",
              "@prefix ensembl: <http://identifiers.org/ensembl/> ."
            ]
          end


          # opts:
          # :remove_zero remove values for which fpkms is zero
          # :sample name of the sample
          # :project name of the project
          # :run name of the run
          # :compact remove data that are repeated inside the knowledgebase like location information
          def to_ttl(opts={})#name=nil, project = nil, run = nil)

            puts prefix

            #gff = GFF3.open(ARGV.shift)

            #gff.each_gene do |gene|
            #  gene_id = gene.label
            #gene_uri = uri

            #  triple(gene_uri, "rdf:type", "obo:SO_0000704") # so:gene
            #  triple(gene_uri, "rdfs:label", quote(gene_id))
            #  triple(gene_uri, "gtf:parent_chromosome", quote(chromosome_id))

            each_transcript do |transcript|

unless opts[:remove_zero] && transcript.attributes[:FPKM] == 0.0

              transcript_id = transcript.attributes[:transcript_id]
              transcript_uri = "ensembl:#{transcript_id}" #uri(domain:"ensembl",entity:transcript_id)
              transcript_uuid = uri

              triple(transcript_uri, "rdf:type", "ns0:SO_0000833") # so:transcript
              triple(transcript_uri, "rdfs:label", quote(transcript_id))
              # triple(transcript_uri, "gtf:parent_gene", uri(domain:"ensembl", entity:transcript.attributes[:gene_id]))
              triple(transcript_uri, "gtf_vocabulary:parent_gene", "ensembl:#{transcript.attributes[:gene_id]}")
              #triple(transcript_uri, "gtf:parent_gene", gene_uri)
              triple(transcript_uri, "gtf:uuid", transcript_uuid)
              if opts[:sample]
                triple(uri(domain:"sample",entity:opts[:sample]), "ngs:hasTranscript", transcript_uuid) 
                triple(transcript_uuid, "ngs:sample", uri(domain:"sample",entity:opts[:sample])) 
              end
              if opts[:project] 
                triple( uri(domain:"project",entity:opts[:project]), "ngs:hasTranscript",transcript_uuid)
                triple(transcript_uuid, "ngs:project", uri(domain:"project",entity:opts[:project]))
              end
              if opts[:run]
                triple(uri(domain:"run",entity:opts[:run]), "ngs:hasTranscript",transcript_uuid)
                triple(transcript_uuid, "ngs:run", uri(domain:"run",entity:opts[:run]))
              end
          

# http://genome.db/coords/1-62948-63887-f
              unless opts[:compact] == true
strand = case transcript.strand
when '+' then 'f'
when '-' then 'r'
when '.' then ''
end

coord_partial = []
              exon = Bio::Ngs::Cufflinks::Exon.new

              transcript.each_exon do |e|

                exon.set e
                #exon_id = exon.attrbutes[:gene_id]
                exon_uri = uri
coord_partial<<"#{transcript.seqname}##{exon.start}_#{exon.stop}"
end 

coord= "#{transcript.seqname}:" + coord_partial.join('-') + ":#{strand.empty? ? '' : strand}"
triple(transcript_uri, "gtf:location", uri(domain:"coords",entity:coord))
triple(uri(domain:"coords",entity:coord), "a", "gtf:cufflinks_transcript")
triple(uri(domain:"coords",entity:coord), "gtf:seqname", quote(transcript.seqname))
triple(uri(domain:"coords",entity:coord), "gtf:start", transcript.start)
triple(uri(domain:"coords",entity:coord), "gtf:stop", transcript.stop)
triple(uri(domain:"coords",entity:coord), "gtf:strand", quote(transcript.strand))
end #if compact transcript

# http://genome.db/coords/1-62948-63887-f rdf:type genome:Location
# http://genome.db/coords/1-62948-63887-f gtf:start 62948
# http://genome.db/coords/1-62948-63887-f gtf:stop 63887
# http://genome.db/coords/1-62948-63887-f gtf:strand "+"



              ## Common with GFF
              # triple(transcript_uuid, "gtf:seqname", quote(transcript.seqname))
              # %w(start stop score).each do |key|
              #   triple(transcript_uri, "gtf:#{key}", transcript.send(key))
              # end
              # # string
              # %w(strand frame).each do |key|
              #   triple(transcript_uri, "gtf:#{key}", quote(transcript.send(key)))
              # end

              ## Specific to GTF (cufflinks)
              # float
              %w(FPKM frac conf_lo conf_hi cov).each do |key|
                triple(transcript_uuid, "gtf:#{key}", transcript.attributes[key.to_sym])
              end
              # string
              %w(full_read_support).each do |key|
                triple(transcript_uuid, "gtf:#{key}", quote(transcript.attributes[key.to_sym]))
              end

              # exon = Bio::Ngs::Cufflinks::Exon.new
unless opts[:compact]==true
              transcript.each_exon do |e|

                exon.set e
                #exon_id = exon.attrbutes[:gene_id]
                exon_uri = uri

                triple(exon_uri, "rdf:type", "ns0:SO_0000852") # so:exon
                # triple(exon_uri, "rdfs:label", quote(exon_id))
                triple(exon_uri, "gtf:parent_transcript", transcript_uuid)

coord = "#{exon.start}_#{exon.stop}"
triple(exon_uri, "gtf:location", uri(domain:"coords",entity:coord))
triple(uri(domain:"coords",entity:coord), "a", "gtf:caffulinks_exon")
triple(uri(domain:"coords",entity:coord), "gtf:seqname", quote(transcript.seqname))
triple(uri(domain:"coords",entity:coord), "gtf:start", exon.start)
triple(uri(domain:"coords",entity:coord), "gtf:stop", exon.stop)
triple(uri(domain:"coords",entity:coord), "gtf:strand", quote(transcript.strand))
triple(uri(domain:"coords",entity:coord), "gtf:exon_number", exon.attributes[:exon_number])



                ## Common with GFF
                # int
                # %w(start stop).each do |key|
                #   triple(exon_uri, "gtf:#{key}", exon.send(key))
                # end
                ## Specific to GTF (cufflinks/cuffcompare)
                # int
                # %w(exon_number).each do |key|
                #   triple(exon_uri, "gtf:#{key}", exon.attributes[key.to_sym])
                # end
                # string
                %w(oId).each do |key|
                  triple(exon_uri, "gtf:#{key}", quote(exon.attributes[key.to_sym])) unless exon.attributes[key.to_sym].nil?
                end
              end #each_exon
            end #if compact exons
            end #unless
            end #each_transcript
            #end #Gene
          end # to_ttl
        end #RDF
      end #Gtf
    end #Cufflinks
  end #Ngs
end #Bio
