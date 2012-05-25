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
            #{}"filenames"    => filenames_paths
          }.to_json(*a)
        end

        def self.json_create(o)
          me = new(o["name"], o["metadata"]["path"],o["metadata"]["parent"])
        end
      end #File

      class Sample < Meta::Pool
        #attr_accessor :name #, :filenames
        def initialize(name, path, parent=nil)
          super(name)
          metadata[:path]=path
          @parent = parent
        end

        def path
          File.join @parent.path,"Sample_#{name}"
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
          end

          if filename=~/filtered|FILTERED/
            metadata[:filtered] = true
            metadata[:filtered_aggregated] =true unless filename=~/_\d+\./
          end
          metadata[:left] = true if filename=~/.*_R1_.*/
          metadata[:right] = true if filename=~/.*_R2_.*/
          metadata[:zipped] = true if filename=~/\.gz/
          metadata[:aggregated] = true unless metadata[:trimmed_aggregated] || metadata[:filtered_aggregated] || filename=~/_\d+\./

          filename.sub!(/_([ACGT]+)_/,'_')
          metadata[:index] = $1
          filename.sub!(/_L([0-9]+)_?/,'_')
          metadata[:lane] = $1

          #filename_cleaned = filename.sub(/_R.*/,'')
          readsdata_name = File.basename(filename).sub(/TRIMMED/,'').sub(/trimmed/,'').sub(/filtered/,'').sub(/FILTERED/,'').sub(/_R\d+_\d+_?/,'').sub(/_R\d+_/,'').sub(/\..+$/,'') #TODO is not the best thing to do

            if filename=~/R._(\d*).fastq(.gz)?/
              metadata[:chunks]=$1
            end
            self.add MetaReads.new(SecureRandom.uuid, metadata)
          end

          #REMOVE          # def get(tag=filtered)
          #   @files.get(tag)
          # end

          def filenames_paths
            @filenames.keys.map do |filename|
              filename_path(filename)
            end.flatten
          end

          def to_json(*a)
            {
              "json_class"   => self.class.name,
              "name"         => name,
              "metadata"     => metadata,
              "files"        => pool
            }.to_json(*a)
          end

          # def self.json_create(o)
          #   me = new(o["name"], o["metadata"]["path"],o["metadata"]["parent"])
          # end
        end #Sample
      end #Illumina
    end #Ngs
  end #Bio
