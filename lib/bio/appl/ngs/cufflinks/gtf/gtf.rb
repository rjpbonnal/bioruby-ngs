module Bio
  module Ngs
    module Cufflinks
      class Gtf
        #include MarkCall
        include GtfParser
        def initialize(file)
          @fh=File.open(File.absolute_path(file))
        end

        def source
          @fh
        end

      end #Gtf

    end
  end
end