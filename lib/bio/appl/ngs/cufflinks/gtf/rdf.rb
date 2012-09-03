module Bio
  module Ngs
    module Cufflinks
      class Gtf
        module RDF
          require 'securerandom'

          def uri(str = nil)
            if str
              return "<http://genome.db/cufflinks/#{str}>"

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
              "@prefix obo: <http://purl.obolibrary.org/obo/> .",
              "@prefix gtf: <http://genome.db/gtf/> .",
              "@prefix ngs: <http://genome.db/ngs/> .",
            ]
          end


          def to_ttl(opts={})#name=nil, project = nil, run = nil)

            puts prefix

            #gff = GFF3.open(ARGV.shift)

            #gff.each_gene do |gene|
            #  gene_id = gene.label
            gene_uri = uri

            #  triple(gene_uri, "rdf:type", "obo:SO_0000704") # so:gene
            #  triple(gene_uri, "rdfs:label", quote(gene_id))
            #  triple(gene_uri, "gtf:parent_chromosome", quote(chromosome_id))

            each_transcript do |transcript|
              transcript_id = transcript.attributes[:gene_id]
              transcript_uri = uri(transcript_id)
              transcript_iid = uri

              triple(transcript_uri, "rdf:type", "obo:SO_0000673") # so:transcript
              triple(transcript_uri, "rdfs:label", quote(transcript_id))
              triple(transcript_uri, "gtf:parent_gene", gene_uri)
              triple(transcript_uri, "gtf:iid", transcript_iid)
              triple(transcript_uri, "ngs:sample", quote(opts[:sample])) if opts[:sample]
              triple(transcript_uri, "ngs:project", quote(opts[:project])) if opts[:project] 
              triple(transcript_uri, "ngs:run", quote(opts[:run])) if opts[:run]

              ## Common with GFF
              # int
              triple(transcript_iid, "gtf:seqname", quote(transcript.seqname))
              %w(start stop score).each do |key|
                triple(transcript_iid, "gtf:#{key}", transcript.send(key))
              end
              # string
              %w(strand frame).each do |key|
                triple(transcript_iid, "gtf:#{key}", quote(transcript.send(key)))
              end
              ## Specific to GTF (cufflinks)
              # float
              %w(FPKM frac conf_lo conf_hi cov).each do |key|
                triple(transcript_iid, "gtf:#{key}", transcript.attributes[key.to_sym])
              end
              # string
              %w(full_read_support).each do |key|
                triple(transcript_iid, "gtf:#{key}", quote(transcript.attributes[key.to_sym]))
              end

              transcript.each_exon do |e|
                #TODO Fix this ugly call
                exon=Bio::Ngs::Cufflinks::Exon.new
                exon=e
                #exon_id = exon.attrbutes[:gene_id]
                exon_uri = uri

                triple(exon_uri, "rdf:type", "obo:SO_0000147") # so:exon
                # triple(exon_uri, "rdfs:label", quote(exon_id))
                triple(exon_uri, "gtf:parent_transcript", transcript_iid)

                ## Common with GFF
                # int
                %w(start end).each do |key|
                  triple(exon_uri, "gtf:#{key}", exon.send(key))
                end
                ## Specific to GTF (cufflinks/cuffcompare)
                # int
                %w(exon_number).each do |key|
                  triple(exon_uri, "gtf:#{key}", exon.attributes[key.to_sym])
                end
                # string
                %w(oId).each do |key|
                  triple(exon_uri, "gtf:#{key}", quote(exon.attributes[key.to_sym]))
                end
              end #each_exon
            end #each_transcript
            #end #Gene
          end # to_ttl
        end #RDF
      end #Gtf
    end #Cufflinks
  end #Ngs
end #Bio
