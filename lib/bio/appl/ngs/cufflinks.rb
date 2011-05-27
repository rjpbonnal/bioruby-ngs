#
#   cufflinks.rb - description
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#



module Bio
  module Ngs    
    module Cufflinks

      # cufflinks v0.9.3
      # linked against Boost version 104000
      # -----------------------------
      # Usage:   cufflinks [options] <hits.sam>
      # Options:
      # 
      #   -p/--num-threads             number of threads used during analysis                [ default:      1 ]
      #   -L/--label                   assembled transcripts have this ID prefix             [ default:   CUFF ]
      #   -G/--GTF                     quantitate against reference transcript annotations                      
      #   -F/--min-isoform-fraction    suppress transcripts below this abundance level       [ default:   0.15 ]
      #   -f/--min-intron-fraction     filter spliced alignments below this level            [ default:   0.05 ]
      #   -j/--pre-mrna-fraction       suppress intra-intronic transcripts below this level  [ default:   0.15 ]
      #   -I/--max-intron-length       ignore alignments with gaps longer than this          [ default: 300000 ]
      #   -Q/--min-map-qual            ignore alignments with lower than this mapping qual   [ default:      0 ]
      #   -M/--mask-file               ignore all alignment within transcripts in this file                     
      #   -v/--verbose                 log-friendly verbose processing (no progress bar)     [ default:  FALSE ]
      #   -q/--quiet                   log-friendly quiet processing (no progress bar)       [ default:  FALSE ]
      #   -o/--output-dir              write all output files to this directory              [ default:     ./ ]
      #   -r/--reference-seq           reference fasta file for sequence bias correction     [ default:   NULL ]
      # 
      # Advanced Options:
      # 
      #   -N/--quartile-normalization  use quartile normalization instead of total counts    [ default:  FALSE ]
      #   -a/--junc-alpha              alpha for junction binomial test filter               [ default:   0.01 ]
      #   -A/--small-anchor-fraction   percent read overhang taken as 'suspiciously small'   [ default:   0.12 ]
      #   -m/--frag-len-mean           the average fragment length                           [ default:    200 ]
      #   -s/--frag-len-std-dev        the fragment length standard deviation                [ default:     80 ]
      #   --min-frags-per-transfrag    minimum number of fragments needed for new transfrags [ default:     10 ]
      #   --overhang-tolerance         number of terminal exon bp to tolerate in introns     [ default:      8 ]
      #   --num-importance-samples     number of importance samples for MAP restimation      [ default:   1000 ]
      #   --max-mle-iterations         maximum iterations allowed for MLE calculation        [ default:   5000 ]
      #   --library-type               Library prep used for input reads                     [ default:  below ]
      #   --max-bundle-length          maximum genomic length allowed for a given bundle     [ default:3500000 ]
      #   --min-intron-length          minimum intron size allowed in genome                 [ default:     50 ]
      # Supported library types:
      #   ff-firststrand
      #   ff-secondstrand
      #   ff-unstranded
      #   fr-firststrand
      #   fr-secondstrand
      #   fr-unstranded (default)
      #   transfrags      
      class Quantification

        include Bio::Command::Wrapper

        set_program Bio::Ngs::Utils.binary("cufflinks/cufflinks")

        add_option "num-threads", :type => :numeric, :aliases => '-p', :default => 1
        add_option "label", :type => :string, :aliases => '-L', :default => "CUFF"
        add_option "GTF", :type => :string, :aliases => '-G'
        add_option "min-isoform-fraction", :type => :numeric, :aliases => '-F', :default => 0.15
        add_option "min-intron-fraction", :type => :numeric, :aliases => '-f', :default => 0.05
        add_option "pre-mrna-fraction", :type => :numeric, :aliases => '-j', :default => 0.15
        add_option "max-intron-length", :type => :numeric, :aliases => '-I', :default => 300000
        add_option "min-map-qual", :type => :numeric, :aliases => '-Q', :default => 0
        add_option "mask-file", :type => :string, :aliases => '-M'
        add_option "verbose", :type => :boolean, :aliases => '-v'
        add_option "quiet", :type => :boolean, :aliases => '-q'
        add_option "output-dir", :type => :string, :aliases => '-o', :default => "./"
        add_option "reference-seq", :type => :string, :aliases => '-r'
        add_option "quartile-normalization", :type => :boolean, :aliases => '-N'
        add_option "junc-alpha", :type => :numeric, :aliases => '-a', :default => 0.01
        add_option "small-anchor-fraction", :type => :numeric, :aliases => '-A', :default => 0.12
        #TODO Check why with these defaults is not working properly
        add_option "farg-len-mean", :type => :numeric, :aliases => '-m'#, :default => 200
        add_option "frag-len-std-dev", :type => :numeric, :aliases => '-s'#, :default => 80
        add_option "min-frags-per-transfrag", :type => :numeric#, :default => 10
        add_option "overhang-tolerance", :type => :numeric#, :default => 8
        add_option "num-importance-samples", :type => :numeric#, :default => 1000
        add_option "max-mle-iterations", :type => :numeric#, :default => 5000
        add_option "library-type", :type => :string
        add_option "max-bundle-length", :type => :numeric#, :default => 3500000
        add_option "min-intron-length", :type => :numeric#, :default => 50
      end #Quantification  
      
      # cuffdiff v1.0.2 (2336)
      # -----------------------------
      # Usage:   cuffdiff [options] <transcripts.gtf> <sample1_hits.sam> <sample2_hits.sam> [... sampleN_hits.sam]
      #    Supply replicate SAMs as comma separated lists for each condition: sample1_rep1.sam,sample1_rep2.sam,...sample1_repM.sam
      # General Options:
      #   -o/--output-dir              write all output files to this directory              [ default:     ./ ]
      #   -T/--time-series             treat samples as a time-series                        [ default:  FALSE ]
      #   -c/--min-alignment-count     minimum number of alignments in a locus for testing   [ default:   10 ]
      #   --FDR                        False discovery rate used in testing                  [ default:   0.05 ]
      #   -M/--mask-file               ignore all alignment within transcripts in this file  [ default:   NULL ]
      #   -b/--frag-bias-correct       use bias correction - reference fasta required        [ default:   NULL ]
      #   -u/--multi-read-correct      use 'rescue method' for multi-reads (more accurate)   [ default:  FALSE ]
      #   -N/--upper-quartile-norm     use upper-quartile normalization                      [ default:  FALSE ]
      #   -L/--labels                  comma-separated list of condition labels
      #   -p/--num-threads             number of threads used during quantification          [ default:      1 ]
      # 
      # Advanced Options:
      #   --library-type               Library prep used for input reads                     [ default:  below ]
      #   -m/--frag-len-mean           average fragment length (unpaired reads only)         [ default:    200 ]
      #   -s/--frag-len-std-dev        fragment length std deviation (unpaired reads only)   [ default:     80 ]
      #   --num-importance-samples     number of importance samples for MAP restimation      [ default:   1000 ]
      #   --max-mle-iterations         maximum iterations allowed for MLE calculation        [ default:   5000 ]
      #   --compatible-hits-norm       count hits compatible with reference RNAs only        [ default:  TRUE  ]
      #   --total-hits-norm            count all hits for normalization                      [ default:  FALSE ]
      #   --poisson-dispersion         Don't fit fragment counts for overdispersion          [ default:  FALSE ]
      #   -v/--verbose                 log-friendly verbose processing (no progress bar)     [ default:  FALSE ]
      #   -q/--quiet                   log-friendly quiet processing (no progress bar)       [ default:  FALSE ]
      #   --no-update-check            do not contact server to check for update availability[ default:  FALSE ]
      #   --emit-count-tables          print count tables used to fit overdispersion         [ default:  FALSE ]
      # 
      # Supported library types:
      #   ff-firststrand
      #   ff-secondstrand
      #   ff-unstranded
      #   fr-firststrand
      #   fr-secondstrand
      #   fr-unstranded (default)
      #   transfrags
      class Diff
        include Bio::Command::Wrapper

        set_program Bio::Ngs::Utils.binary("cufflinks/cuffdiff")
        
        add_option "output-dir", :type => :string, :aliases => '-o', :default => "./"
        add_option "time-series", :type => :boolean, :aliases => '-T'
        add_option "min-alignment-count", :type => :numeric, :aliases => '-c'
        add_option "FDR", :type => :numeric, :aliases => '-F'
#TODO:FIX        add_option "mask-file", :type => :string, :aliases => '-M'
#TODO:FIX        add_option "frag-bias-correct", :type => 
        add_option "multi-read-correct", :type => :boolean, :aliases => '-u'
        add_option "upper-quartile-norm", :type => :boolean, :aliases => 'N'
        add_option "labels", :type => :array, :aliases => '-L'
        add_option "num-threads", :type => :numeric, :aliases => '-p'
        add_option "library-type", :type => :string, :aliases => '-l'
        add_option "frag-len-mean", :type => :numeric, :aliases => '-m'
        add_option "frag-len-std-dev", :type => :numeric, :aliases => '-s'
        add_option "num-importance-samples", :type => :numeric, :aliases => '-i'
        add_option "max-mle-iterations", :type => :numeric, :aliases => '-e'
        add_option "compatible-hits-norm", :type => :boolean, :aliases => '-h'
        add_option "total-hits-norm", :type => :boolean, :aliases => '-t'
        add_option "poisson-dispersion", :type => :boolean, :aliases => '-d'
        add_option "verbose", :type => :boolean, :aliases => '-v'
        add_option "quiet", :type => :boolean, :aliases => '-q'
        add_option "no-update-check", :type => :boolean, :aliases => '-j'
        add_option "emit-count-tables", :type => :boolean, :aliases => '-b'
        
      end #Diff
    end #Cufflinks
  end #Ngs
end #Bio