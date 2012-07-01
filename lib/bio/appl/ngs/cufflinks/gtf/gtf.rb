module Bio
  module Ngs
    module Cufflinks
      class Gtf
        #include MarkCall
        attr_accessor :new_tag
        include GtfParser
        def initialize(file, opt={})
          @fh=File.open(File.absolute_path(file))
          @new_tag = opt[:tag] || "CUFF"
        end

        def source
          @fh
        end

        def source=(src)
          @fh=src
        end

      end #Gtf

    end
  end
end