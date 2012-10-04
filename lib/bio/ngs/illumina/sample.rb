#TODO: refactor this code, I don't like it very much
#TODO: export in JSON format
require 'meta'
require 'securerandom'

module Bio
  module Ngs
    module Illumina
      class MetaReads < Meta::Data
        def initialize(name, metadata={})
          super(name, metadata)
          metadata[:type]=:file
          metadata[:format]=:fastq
        end

        def to_json(*a)
          {
            "json_class"   => self.class.name,
            "name"         => name,
            "metadata"     => metadata
          }.to_json(*a)
        end

        def self.json_create(o)
          me = new(o["name"], o["metadata"])
        end
      end #File

      class Sample < Meta::Pool
        #attr_accessor :name #, :filenames
        def initialize(name, path, parent=nil)
          super(name)
          metadata[:path]=path
          @parent = parent
        end

        alias :each_file :each

        def project_path
          File.join @parent.path,"Sample_#{name}"
        end

        def path
          File.join "Sample_#{name}"
        end


        def paired?
          @filenames.key?(:left) && @filenames.key?(:right)
        end

        def add_filename(filename)
          filename_metadata = filename.dup
          metadata = {:filename=>filename_metadata}
          #TODO maybe could be usefult to leave this to end used, define what is a filtered/trimmed file. Define a regexp for each category.
          if filename=~/trimmed|TRIMMED/
            metadata[:trimmed] = true
            metadata[:trimmed_aggregated] = true unless filename=~/_\d+\./
          else
            metadata[:trimmed] = false
          end

          if filename=~/unpaired|UNPAIRED/
            metadata[:unpaired] = true
            metadata[:unpaired_aggregated] = true unless filename=~/_\d+\./
          else
            metadata[:unpaired] = false
          end


          if filename=~/filtered|FILTERED/
            metadata[:filtered] = true
            metadata[:filtered_aggregated] =true unless filename=~/_\d+\./
          else
            metadata[:filtered] = false
          end

          if filename=~/Undetermined/
            metadata[:undetermined] = true
          else
            metadata[:undetermined] = false
          end


          if filename=~/.*_R1_?.*/
            metadata[:left] = true 
            metadata[:side] = :left
          end
          if filename=~/.*_R2_?.*/
            metadata[:right] = true 
            metadata[:side] = :right
          end

          metadata[:zipped] = true if filename=~/\.gz/
          metadata[:aggregated] = true unless metadata[:trimmed_aggregated] || metadata[:filtered_aggregated] || filename=~/_\d+\./

          filename.sub!(/_([ACGT]+)_/,'_')
          metadata[:index] = $1
          filename.sub!(/_L([0-9]+)_?/,'_')
          metadata[:lane] = $1

          #filename_cleaned = filename.sub(/_R.*/,'')
          readsdata_name = File.basename(filename).sub(/TRIMMED/,'').sub(/trimmed/,'').sub(/filtered/,'').sub(/FILTERED/,'').sub(/_R\d+_\d+_?/,'').sub(/_R\d+_/,'').sub(/\..+$/,'') #TODO is not the best thing to do

            if filename=~/R._(\d*).*.fastq(.gz)?/
              metadata[:chunks]=$1
            end
            self.add MetaReads.new(SecureRandom.uuid, metadata)
          end

          def filenames_paths
            @filenames.keys.map do |filename|
              filename_path(filename)
            end.flatten
          end

          def chunks
            chunks_id = []
            each_file do |file_name, reads|
              chunks_id << reads.metadata[:chunks]
            end
            chunks_id.uniq.sort
          end

          def lanes
            lanes_id = []
            each_file do |file_name, reads|
              lanes_id << reads.metadata[:lane]
            end
            lanes_id.uniq.sort
          end

          def right
            get :side, :right
          end

          def left
            get :side, :left
          end

          def to_json(*a)
            {
              "json_class"   => self.class.name,
              "name"         => name,
              "metadata"     => metadata,
              "files"        => pool
            }.to_json(*a)
          end

          # Return an hash with forward/reverse
          def aggregate_by_chunks
            forward = []
            reverse = []
            chunks.each do |chunk|
              reads=get :chunks, chunk
               forward << (get :side, :left)
               reverse << (get :side, :right)
            end
            [forward,reverse]
          end

          # def self.json_create(o)
          #   me = new(o["name"], o["metadata"]["path"],o["metadata"]["parent"])
          # end
        end #Sample
      end #Illumina
    end #Ngs
  end #Bio
