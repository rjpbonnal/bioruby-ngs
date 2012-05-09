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
      VERSION = "1.0.X"
      class << self
        def version
          VERSION
        end
      end

      module MarkCall
        def mark
          puts caller.first #elaborate the concept of tracking but not here please.
        end
      end


    # cufflinks v1.3.0
    # linked against Boost version 104000
    # -----------------------------
    # Usage:   cufflinks [options] <hits.sam>
    # General Options:
    #   -o/--output-dir              write all output files to this directory              [ default:     ./ ]
    #   -p/--num-threads             number of threads used during analysis                [ default:      1 ]
    #   --seed                       value of random number generator seed                 [ default:      0 ]
    #   -G/--GTF                     quantitate against reference transcript annotations
    #   -g/--GTF-guide               use reference transcript annotation to guide assembly
    #   -M/--mask-file               ignore all alignment within transcripts in this file
    #   -b/--frag-bias-correct       use bias correction - reference fasta required        [ default:   NULL ]
    #   -u/--multi-read-correct      use 'rescue method' for multi-reads (more accurate)   [ default:  FALSE ]
    #   --library-type               library prep used for input reads                     [ default:  below ]
    #
    # Advanced Abundance Estimation Options:
    #   -m/--frag-len-mean           average fragment length (unpaired reads only)         [ default:    200 ]
    #   -s/--frag-len-std-dev        fragment length std deviation (unpaired reads only)   [ default:     80 ]
    #   --upper-quartile-norm        use upper-quartile normalization                      [ default:  FALSE ]
    #   --max-mle-iterations         maximum iterations allowed for MLE calculation        [ default:   5000 ]
    #   --num-importance-samples     number of importance samples for MAP restimation      [ default:   1000 ]
    #   --compatible-hits-norm       count hits compatible with reference RNAs only        [ default:  FALSE ]
    #   --total-hits-norm            count all hits for normalization                      [ default:  TRUE  ]
    #
    # Advanced Assembly Options:
    #   -L/--label                   assembled transcripts have this ID prefix             [ default:   CUFF ]
    #   -F/--min-isoform-fraction    suppress transcripts below this abundance level       [ default:   0.10 ]
    #   -j/--pre-mrna-fraction       suppress intra-intronic transcripts below this level  [ default:   0.15 ]
    #   -I/--max-intron-length       ignore alignments with gaps longer than this          [ default: 300000 ]
    #   -a/--junc-alpha              alpha for junction binomial test filter               [ default:  0.001 ]
    #   -A/--small-anchor-fraction   percent read overhang taken as 'suspiciously small'   [ default:   0.09 ]
    #   --min-frags-per-transfrag    minimum number of fragments needed for new transfrags [ default:     10 ]
    #   --overhang-tolerance         number of terminal exon bp to tolerate in introns     [ default:      8 ]
    #   --max-bundle-length          maximum genomic length allowed for a given bundle     [ default:3500000 ]
    #   --max-bundle-frags           maximum fragments allowed in a bundle before skipping [ default: 500000 ]
    #   --min-intron-length          minimum intron size allowed in genome                 [ default:     50 ]
    #   --trim-3-avgcov-thresh       minimum avg coverage required to attempt 3' trimming  [ default:     10 ]
    #   --trim-3-dropoff-frac        fraction of avg coverage below which to trim 3' end   [ default:    0.1 ]
    #
    # Advanced Reference Annotation Guided Assembly Options:
    #   --no-faux-reads              disable tiling by faux reads                          [ default:  FALSE ]
    #   --3-overhang-tolerance       overhang allowed on 3' end when merging with reference[ default:    600 ]
    #   --intron-overhang-tolerance  overhang allowed inside reference intron when merging [ default:     30 ]
    #
    # Advanced Program Behavior Options:
    #   -v/--verbose                 log-friendly verbose processing (no progress bar)     [ default:  FALSE ]
    #   -q/--quiet                   log-friendly quiet processing (no progress bar)       [ default:  FALSE ]
    #   --no-update-check            do not contact server to check for update availability[ default:  FALSE ]
    #
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
      include Bio::Ngs::Cufflinks::Utils

      set_program Bio::Ngs::Utils.binary("cufflinks")

      add_option "output-dir", :type => :string, :aliases => '-o', :default => "./"
      add_option "num-threads", :type => :numeric, :aliases => '-p', :default => 1
      add_option "seed", :type => :numeric
      add_option "GTF", :type => :string, :aliases => '-G'
      add_option "GTF-guide", :type => :string, :aliases => '-g'
      add_option "mask-file", :type => :string, :aliases => '-M'
      add_option "frag-bias-correct", :type => :string, :aliases => '-b'
      add_option "multi-read-correct", :type => :boolean, :aliases => '-u'
      add_option "library-type", :type => :string
      add_option "farg-len-mean", :type => :numeric, :aliases => '-m'#, :default => 200
      add_option "frag-len-std-dev", :type => :numeric, :aliases => '-s'#, :default => 80
      add_option "upper-quartile-norm", :type => :boolean
      add_option "max-mle-iterations", :type => :numeric#, :default => 5000
      add_option "num-importance-samples", :type => :numeric#, :default => 1000
      add_option "compatible-hits-norm", :type => :boolean, :aliases => '-h'
      add_option "total-hits-norm", :type => :boolean, :aliases => '-t'
      add_option "label", :type => :string, :aliases => '-L', :default => "CUFF"
      add_option "min-isoform-fraction", :type => :numeric, :aliases => '-F', :default => 0.15
      add_option "pre-mrna-fraction", :type => :numeric, :aliases => '-j', :default => 0.15
      #deprecated        add_option "min-intron-fraction", :type => :numeric, :aliases => '-f', :default => 0.05
      add_option "max-intron-length", :type => :numeric, :aliases => '-I', :default => 300000
      add_option "junc-alpha", :type => :numeric, :aliases => '-a', :default => 0.01
      add_option "small-anchor-fraction", :type => :numeric, :aliases => '-A', :default => 0.12
      add_option "min-frags-per-transfrag", :type => :numeric#, :default => 10
      add_option "overhang-tolerance", :type => :numeric#, :default => 8
      add_option "max-bundle-length", :type => :numeric #, :default => 3500000
      add_option "max-bundle-frags", :type => :numeric #, :default => 500000
      add_option "min-intron-length", :type => :numeric#, :default => 50
      add_option "trim-3-avgcov-thresh", :type => :numeric
      add_option "trim-3-dropoff-frac", :type => :numeric
      add_option "no-faux-reads", :type => :boolean
      add_option "3-overhang-tolerance", :type => :numeric
      add_option "intron-overhang-tolerance", :type => :numeric
      add_option "verbose", :type => :boolean, :aliases => '-v'
      add_option "quiet", :type => :boolean, :aliases => '-q'

      #deprecated        add_option "min-map-qual", :type => :numeric, :aliases => '-Q', :default => 0
      #deprecated        add_option "reference-seq", :type => :string, :aliases => '-r'
      #deprecated        add_option "quartile-normalization", :type => :boolean, :aliases => '-N'

      #TODO Check why with these defaults is not working properly



      add_iterator_for :genes
      add_iterator_for :isoforms




    end #Quantification


    class QuantificationDenovo  < Quantification
      #set_program Bio::Ngs::Utils.binary("cufflinks")
      delete_option "GTF"
      #add_option "GTF-guide", :type => :string, :aliases => '-g'
      #        add_alias "GTF", "GTF-guide"

      # returns new trascripts from a gff3 file, it creates the file if doesn't exist
      # gets only the brand new.
      def get_new_transcripts(file=nil, type="gtf")
        # TODO implement conversion to gff3
        file||= "transcripts.#{type}"
        # if type=="gtf"
        # unless File.exists?(file)
        #   to_gff3(File.dirname(File.absolute_path(file)))
        # end
        File.open()
      end
    end

    # cuffdiff v1.3.0 (3022)
    # -----------------------------
    # Usage:   cuffdiff [options] <transcripts.gtf> <sample1_hits.sam> <sample2_hits.sam> [... sampleN_hits.sam]
    #    Supply replicate SAMs as comma separated lists for each condition: sample1_rep1.sam,sample1_rep2.sam,...sample1_repM.sam
    # General Options:
    #   -o/--output-dir              write all output files to this directory              [ default:     ./ ]
    #   --seed                       value of random number generator seed                 [ default:      0 ]
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
    #   --num-bootstrap-samples      Number of bootstrap replications                      [ default:     20 ]
    #   --bootstrap-fraction         Fraction of fragments in each bootstrap sample        [ default:    1.0 ]
    #   --max-mle-iterations         maximum iterations allowed for MLE calculation        [ default:   5000 ]
    #   --compatible-hits-norm       count hits compatible with reference RNAs only        [ default:   TRUE ]
    #   --total-hits-norm            count all hits for normalization                      [ default:  FALSE ]
    #   --poisson-dispersion         Don't fit fragment counts for overdispersion          [ default:  FALSE ]
    #   -v/--verbose                 log-friendly verbose processing (no progress bar)     [ default:  FALSE ]
    #   -q/--quiet                   log-friendly quiet processing (no progress bar)       [ default:  FALSE ]
    #   --no-update-check            do not contact server to check for update availability[ default:  FALSE ]
    #   --emit-count-tables          print count tables used to fit overdispersion         [ default:  FALSE ]
    #   --max-bundle-frags           maximum fragments allowed in a bundle before skipping [ default: 500000 ]
    #
    # Debugging use only:
    #   --read-skip-fraction         Skip a random subset of reads this size               [ default:    0.0 ]
    #   --no-read-pairs              Break all read pairs                                  [ default:  FALSE ]
    #   --trim-read-length           Trim reads to be this long (keep 5' end)              [ default:   none ]
    #   --cov-delta                  Maximum gap between bootstrap and IS                  [ default:   2.0  ]
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
      include Bio::Ngs::Cufflinks::Utils

      set_program Bio::Ngs::Utils.binary("cuffdiff")

      add_option "output-dir", :type => :string, :aliases => '-o', :default => "./"
      add_option "seed", :type => :numeric
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
      add_option "num-bootstrap-samples", :type => :numeric
      add_option "bootstrap-fraction", :type => :numeric
      add_option "max-mle-iterations", :type => :numeric, :aliases => '-e'
      add_option "compatible-hits-norm", :type => :boolean, :aliases => '-h'
      add_option "total-hits-norm", :type => :boolean, :aliases => '-t'
      add_option "poisson-dispersion", :type => :boolean, :aliases => '-d'
      add_option "verbose", :type => :boolean, :aliases => '-v'
      add_option "quiet", :type => :boolean, :aliases => '-q'
      add_option "no-update-check", :type => :boolean, :aliases => '-j'
      add_option "emit-count-tables", :type => :boolean, :aliases => '-b'
      add_option "max-bundle-frags", :type => :numeric
      add_option "read-skip-fraction", :type => :numeric
      add_option "no-read-pairs", :type => :numeric
      add_option "trim-read-length", :type => :numeric
      add_option "cov-delta", :type => :numeric

      #define iterators
      add_iterator_for :genes
      add_iterator_for :isoforms
      add_iterator_for :cds
      add_iterator_for :tss_groups

      #Examples
      #Bio::Ngs::Cufflinks::Diff.isoforms("/Users/bonnalraoul/Desktop/RRep16giugno/DE_lane1-2-3-4-6-8/DE_lane1-2-3-4-6-8/isoform_exp.diff", "/Users/bonnalraoul/Desktop/RRep16giugno/COMPARE_lane1-2-3-4-6-8/COMPARE_lane1-2-3-4-6-8.combined.gtf",1.0,3,0.6,false,true)
      #Bio::Ngs::Cufflinks::Diff.genes("/Users/bonnalraoul/Desktop/RRep16giugno/DE_lane1-2-3-4-6-8/DE_lane1-2-3-4-6-8/gene_exp.diff", "/Users/bonnalraoul/Desktop/RRep16giugno/COMPARE_lane1-2-3-4-6-8/COMPARE_lane1-2-3-4-6-8.combined.gtf",1.0,5,0.5,false,true)

      class << self

        #Return the version of CuffDiff used to produce the output
        def version(diff)
          #cufflink_version_offset = Bio::Ngs::Cufflinks.version
          f=File.open(diff,'r')
          header=f.readline #skip header
          f.close
          cufflink_version_offset = case header.split.size
          when 12
            "0.9.X"
          when 14
            Bio::Ngs::Cufflinks.version #latest
          end
        end#version


        def offset_by_version(cufflinks_version)
          case cufflinks_version
          when "0.9.X"
            0
          when "1.0.X"
            1
          end
        end

        #write a file with the information
        #See process_de for options available
        # Example: Bio::Ngs::Cufflinks::Diff.isoforms("/Users/bonnalraoul/Desktop/RRep16giugno/DEPopNormNOTh2s1NOTh17s1_lane1-2-3-4-6-8/isoform_exp.diff",
        # "/Users/bonnalraoul/Desktop/RRep16giugno/COMPARE_PopNormNOTh2s1NOTh17s1_lane1-2-3-4-6-8/ComparepPopNormNOTh2s1NOTh17s1_lane1-2-3-4-6-8.combined.gtf",
        # fold:0.5,min_samples:5,min_fpkm:0.5,z_scores:true, :regulated=>:up)
        def isoforms(diff, gtf, options={})
          process_de(diff, gtf, options) do |dict_info, diff_reference, gtf_kb, fpkm_values|
            "#{dict_info[:winner].first}\t#{gtf_kb[diff_reference][:nearest_ref]}_#{gtf_kb[diff_reference][:gene_name]}\t#{fpkm_values.join("\t")}"
          end
        end #isoform

        #write a file with the information
        #See process_de for options available
        # Example: Bio::Ngs::Cufflinks::Diff.genes("/Users/bonnalraoul/Desktop/RRep16giugno/DEPopNormNOTh2s1NOTh17s1_lane1-2-3-4-6-8/gene_exp.diff",
        # "/Users/bonnalraoul/Desktop/RRep16giugno/COMPARE_PopNormNOTh2s1NOTh17s1_lane1-2-3-4-6-8/ComparepPopNormNOTh2s1NOTh17s1_lane1-2-3-4-6-8.combined.gtf",
        # fold:0.5,min_samples:5,min_fpkm:0.5,z_scores:true, :regulated=>:up)
        def genes(diff, gtf, options={})
          process_de(diff, gtf, options) do |dict_info, diff_reference, gtf_kb, fpkm_values|
            #            puts diff_reference
            #            puts fpkm_values
            # "#{dict_info[:winner].first}\t#{gtf_kb[diff_reference][:gene_name]}\t#{fpkm_values.join("\t")}"
            #do not use th gtf kb
            "#{dict_info[:winner].first}\t#{dict_info[:gene_name]}\t#{fpkm_values.join("\t")}"
          end
        end #genes

        private
        #Options hash
        # :fold(float), :min_samples(integer), :min_fpkm(float), :only_significative(boolean, false) , :z_score(boolean, false)
        # :regulated(symbol :up or :down default :up)
        # :fpkm_log_two (:true :false, default :true)
        def process_de(diff, gtf, options={})
          #init default options
          fold = options[:fold] || 0.0
          min_samples = options[:min_samples] || 0
          min_fpkm = options[:min_fpkm] || 0.0
          only_significative = options[:only_significative] || false
          z_scores = options[:z_scores] || false
          #TODO improve check on paramters
          regulated =options[:regulated] || :up
          fpkm_log_two = options[:fpkm_log_two] || true
          force_not_significative = options[:force_not_significative] || false

          #set up the kb if not available = pass an option with the path of the kb ?
          gtf_kb = nil###### Bio::Ngs::Cufflinks::Compare.exists_kb?(gtf)  ? Bio::Ngs::Cufflinks::Compare.load_compare_kb(gtf) : Bio::Ngs::Cufflinks::Compare.build_compare_kb(gtf)

          #convert log2 fold value into natural log value (internally computed by cuffdiff)
          fold_log2 = fold
          (fold = fold==0 ? 0.0 : (fold*Math.log(2))) unless fpkm_log_two

          dict=Hash.new {|h, k| h[k]=Hash.new{|hh,kk| hh[kk]=[]}; }
          dict_samples = Hash.new{|h,k| h[k]=""}

          #which offset may I consider to get data from cuffdiff?
          cufflink_version_offset = offset_by_version(version(diff))

          File.open(diff,'r') do |f|
            header=f.readline #skip header

            test_id_idx = 0
            gene_name_idx = 2
            q_first_idx = 3 + cufflink_version_offset
            q_second_idx = 4 + cufflink_version_offset
            fpkm_first_idx = 6 + cufflink_version_offset
            fpkm_second_idx = 7 + cufflink_version_offset
            fold_idx = 8 + cufflink_version_offset
            significant_idx = 11 + cufflink_version_offset + (cufflink_version_offset==1 ? 1 : 0)

            #Commenti:
            # per ogni riga del diff devo salvare il valore dei espressione di ogni test
            # quindi fpkm e se è significativo o meno

            f.each_line do |line|
              data=line.split

              #fix comparison t-test, remove negative symbol e invert comparison: if fold change q1 vs q2 <0 abs(foldchange) & swaap q1,q2
              #              puts data[fold_idx].to_f
              #delete puts "#{data[fold_idx].to_f} #{data[fold_idx].to_f<0}"
              if data[fold_idx].to_f<0
                data[fold_idx]=data[fold_idx][1..-1] #.sub(/-/,"")  remove the minus symbol from the number, the values q1, q2 and their fpkm will be reorganized into the data structure
              else
                #                puts "ciao"
                data[fpkm_first_idx],data[fpkm_second_idx]=data[fpkm_second_idx],data[fpkm_first_idx]
                data[q_first_idx],data[q_second_idx]=data[q_second_idx],data[q_first_idx]
                #delete                puts "#{q_first_idx},#{q_second_idx}"
              end
              #delete                              puts "#{q_first_idx},#{q_second_idx}"
              #delete              puts "#{data[q_first_idx].to_sym} #{data[q_second_idx].to_sym}"
              #delete              puts "#{data[fpkm_first_idx].to_sym} #{data[fpkm_second_idx].to_sym}"


              #0 TCONS
              #4 name sample is the max diff for the item
              #5 name sample is the less diff for the item
              #9 is the fold
              dict_samples[data[q_first_idx]]
              dict_samples[data[q_second_idx]]

              #7 is the fpkm value of max pop/sample
              #8 is the fpkm value of min pop/sample
              k_reference = data[test_id_idx].to_sym #This can be TCONS if isoforms or XLOC if genes

              unless dict[k_reference].key?(:values)
                dict[k_reference][:values]={}
                dict[k_reference][:gene_name]=data[gene_name_idx]
              end
              dict[k_reference][:values][data[q_first_idx].to_sym]=data[fpkm_first_idx].to_f unless dict[k_reference][:values].key?(data[q_first_idx].to_sym)
              dict[k_reference][:values][data[q_second_idx].to_sym]=data[fpkm_second_idx].to_f unless dict[k_reference][:values].key?(data[q_second_idx].to_sym)

              if ((only_significative==true && data[significant_idx]=="yes") ||  ((data[significant_idx]=="yes"||force_not_significative) && data[fold_idx].to_f>=fold)) && data[fpkm_first_idx].to_f>=min_fpkm && data[fpkm_second_idx].to_f>=min_fpkm

                ###### puts data.join(" ") if k_reference == :XLOC_017497
                #TODO refactor: this can be done using lambda
                k_sample = ""
                if regulated==:up

                  k_sample = data[q_first_idx].to_sym
                  #delete                  puts "#{k_sample} #{data[q_second_idx].to_sym}"
                  dict[k_reference][k_sample]<<data[q_second_idx].to_sym
                  #delete                   puts "#{k_reference} #{q_first_idx}, #{q_second_idx}"
                  k_sample
                elsif regulated==:down
                  k_sample = data[q_second_idx].to_sym
                  dict[k_reference][k_sample]<<data[q_first_idx].to_sym
                  k_sample
                end

                #delete   puts dict[k_reference].inspect if k_reference == :XLOC_017497
                #delete puts dict.inspect
                #store fpkm values as well for each pop/sample it should be
                if dict[k_reference][k_sample].size >= min_samples
                  (dict[k_reference][:winner] << k_sample).uniq!
                end
                #delete      puts dict[k_reference].inspect if k_reference == :XLOC_017497
              else
                # k_reference = data[0].to_sym #This can be TCONS if isoforms or XLOC if genes
                #
                # unless dict[k_reference].key?(:values)
                #   dict[k_reference][:values]={}
                # end
                # #TODO add threshold value below min fpkm
                # dict[k_reference][:values][data[q_first_idx].to_sym]=data[fpkm_first_idx].to_f unless dict[k_reference][:values].key?(data[q_first_idx].to_sym)
                # dict[k_reference][:values][data[q_second_idx].to_sym]=data[fpkm_second_idx].to_f unless dict[k_reference][:values].key?(data[q_second_idx].to_sym)
                # #dict[k_reference][:values][data[4].to_sym]=data[7].to_f
              end
              #delete              puts dict[k_reference].inspect

            end #each line
            #example structure
            #{:TCONS_00086164=>{:q5=>[:q1, :q2, :q3, :q6]}, :TCONS_00086166=>{:q5=>[:q1, :q2, :q3, :q4, :q6]}
          end #file.open

          file_lines =[]
          dict.each do |diff_reference, dict_info|

            if dict_info.key?(:winner)
              #puts dict_info.inspect

              #BAD PERFORMANCES use lambda
              valz = case z_scores
              when true
                items=dict_info[:values].sort.map{|sample| sample[1]}
                average = items.average
                stdev = items.standard_deviation
                items.map do |fpkm|
                  (fpkm-average)/stdev
                end
              when false
                dict_info[:values].sort.map{|sample| sample[1]}
              end #case

              #TODO generalize to isoforms and genes now only isoforms
              # puts yield(dict_info, diff_reference, gtf_kb, valz) if diff_reference == :XLOC_017497
              file_lines<< yield(dict_info, diff_reference, gtf_kb, valz) #fpkm_values
              #file_lines<<"#{dict_info[:winner].first}\t#{gtf_kb[diff_reference][:nearest_ref]}_#{gtf_kb[diff_reference][:gene_name]}\t#{valz.join("\t")}"
            else
              #TODO not winner or number of min samples
            end#winner
          end # dict_each
          file_name_output =File.join(File.dirname(diff),File.basename(diff,".diff")+"-f#{fold_log2}_s#{min_samples}_fpkm#{min_fpkm}")
          file_name_output += "_z" if z_scores
          file_name_output += regulated.to_s
          file_name_output += ".txt"
          File.open(file_name_output,'w') do |odiff|
            odiff.puts "sample\thumanized_id\t#{dict_samples.keys.sort.join("\t")}"
            file_lines.sort.each do |file_line|
              odiff.puts file_line
            end#each sorted line
          end#open
        end #process_de
      end

    end #Diff


    # cuffcompare v1.0.2 (2335)
    # -----------------------------
    # Usage:
    # cuffcompare [-r <reference_mrna.gtf>] [-R] [-T] [-V] [-s <seq_path>]
    #     [-o <outprefix>] [-p <cprefix>]
    #     {-i <input_gtf_list> | <input1.gtf> [<input2.gtf> .. <inputN.gtf>]}
    #
    #  Cuffcompare provides classification, reference annotation mapping and various
    #  statistics for Cufflinks transfrags.
    #  Cuffcompare clusters and tracks transfrags across multiple samples, writing
    #  matching transcripts (intron chains) into <outprefix>.tracking, and a GTF
    #  file <outprefix>.combined.gtf containing a nonredundant set of transcripts
    #  across all input files (with a single representative transfrag chosen
    #  for each clique of matching transfrags across samples).
    #
    # Options:
    # -i provide a text file with a list of Cufflinks GTF files to process instead
    #    of expecting them as command line arguments (useful when a large number
    #    of GTF files should be processed)
    #
    # -r  a set of known mRNAs to use as a reference for assessing
    #     the accuracy of mRNAs or gene models given in <input.gtf>
    #
    # -R  for -r option, reduce the set of reference transcripts to
    #     only those found to overlap any of the input loci
    # -M  discard (ignore) single-exon transfrags and reference transcripts
    # -N  discard (ignore) single-exon reference transcripts
    #
    # -s  <seq_path> can be a multi-fasta file with all the genomic sequences or
    #     a directory containing multiple single-fasta files (one file per contig);
    #     lower case bases will be used to classify input transcripts as repeats
    #
    # -d  max distance (range) for grouping transcript start sites (100)
    # -p  the name prefix to use for consensus transcripts in the
    #     <outprefix>.combined.gtf file (default: 'TCONS')
    # -C  include the "contained" transcripts in the .combined.gtf file
    # -G  generic GFF input file(s) (do not assume Cufflinks GTF)
    # -T  do not generate .tmap and .refmap files for each input file
    # -V  verbose processing mode (showing all GFF parsing warnings)
    class Compare
      include Bio::Command::Wrapper

      set_program Bio::Ngs::Utils.binary("cuffcompare")
      use_aliases
      #TODO: add descriptions
      add_option "outprefix", :type => :string, :aliases => '-o', :default => "Comparison"
      add_option "gtf_combine_file", :type => :string, :aliases => '-i'
      add_option "gtf_reference", :type => :string, :aliases => '-r'
      add_option "only_overlap", :type => :boolean, :aliases => '-R'
      add_option "discard_transfrags", :type => :boolean, :aliases => '-M'
      add_option "discard_ref_transcripts", :type => :boolean, :aliases => '-N'
      add_option "multi_fasta", :type => :string, :aliases => '-s'
      add_option "distance_tss", :type => :numeric, :aliases => '-d'
      add_option "prefix_transcripts_consensus", :type => :string, :aliases => '-p'
      add_option "contained", :type=>:boolean, :aliases => '-C'
      add_option "GFF", :type => :boolean, :aliases =>'-G'
      add_option "no_map_files", :type => :boolean, :aliases =>'-T'

      class << self

        def kb_name(gtf)
          gtf.sub(/\.[a-zA-Z0-9]*$/,".kb")
        end

        def exists_kb?(gtf)
          File.exists?(kb_name(gtf))
        end

        # Dump an hash of associations from a GTF file generated from CuffCompare
        # gene_id: transcript_id, gene_name, oid, nearest_ref
        #  gene_id example: :XLOC_000001=>{:gene_name=>:RP11-304M2.1, :transcripts=>{:TCONS_00000001=>{:oid=>:ENST00000519787, :nearest_ref=>:ENST00000519787}}}
        # the others are just plain hash
        # transcript_id: gene_id, gene_name, oid, nearest_ref
        # gene_name: gene_id, transcript_id, oid, nearest_ref
        # oid: gene_id, transcript_id, gene_name, nearest_ref
        # nearest_ref: gene_id, transcript_id, gene_name, oid
        #Note:exons and coordinates are not saved.
        def build_compare_kb(gtf)
          unless File.exists?(gtf)
            STDERR.puts "File #{gtf} doesn't exist."
            return nil
          end

          dict = {} #build an hash with the combinations of data extracted from GTF file, XLOC, TCONS, ENST, SYMBOL
          File.open(gtf,'r') do |f|
            f.lines do |line|
              line=~/gene_id (.*?);/
              gene_id = $1.gsub(/"/,'').to_sym
              line=~/transcript_id (.*?);/
              transcript_id = $1.gsub(/"/,'').to_sym
              line=~/gene_name (.*?);/
              gene_name = $1.gsub(/"/,'').to_sym
              line=~/oId (.*?);/
              oid=$1.gsub(/"/,'').to_sym
              line=~/nearest_ref (.*?);/
              nearest_ref = $1.gsub(/"/,'').to_sym
              unless dict.key?(gene_id)
                dict[gene_id]={:gene_name=>gene_name,:transcripts=>{}}
              end
              unless dict[gene_id][:transcripts].key?(transcript_id)
                dict[gene_id][:transcripts][transcript_id]={:odi=>oid, :nearest_ref=>nearest_ref}
              end
              dict[transcript_id]={:gene_id=>gene_id, :gene_name=>gene_name, :odi=>oid, :nearest_ref=>nearest_ref}
              dict[gene_name]={:gene_id=>gene_id, :transcript_id=>transcript_id, :odi=>oid, :nearest_ref=>nearest_ref}
              dict[oid]={:gene_id=>gene_id, :transcript_id=>transcript_id, :gene_name=>gene_name, :nearest_ref=>nearest_ref}
              dict[nearest_ref]={:gene_id=>gene_id, :transcript_id=>transcript_id, :odi=>oid, :gene_name=>gene_name}
            end#lines
          end#file
          kb_filename = kb_name(gtf)
          File.open(kb_filename,'w') do |fkb|
            #fkb.write(dict.to_json)
            Marshal.dump(dict,fkb)
          end #fkb
          dict
        end #build_compare_kb

        # Return the hash of associations
        # gene_id: transcript_id, gene_name, oid, nearest_ref
        # transcript_id: gene_id, gene_name, oid, nearest_ref
        # gene_name: gene_id, transcript_id, oid, nearest_ref
        # oid: gene_id, transcript_id, gene_name, nearest_ref
        # nearest_ref: gene_id, transcript_id, gene_name, oid
        def load_compare_kb(gtf)
          #TODO rescue Exceptions
          kb_filename = kb_name(gtf)
          gtf_kb = File.open(kb_filename,'r') do |kb_dump|
            Marshal.load(kb_dump)
          end
        end #load_compare_kb
      end
    end #Compare

    # cuffmerge takes two or more Cufflinks GTF files and merges them into a
    # single unified transcript catalog.  Optionally, you can provide the script
    # with a reference GTF, and the script will use it to attach gene names and other
    # metadata to the merged catalog.

    # Usage:
    #     cuffmerge [Options] <assembly_GTF_list.txt>

    # Options:
    #     -h/--help                               Prints the help message and exits
    #     -o                     <output_dir>     Directory where merged assembly will be written  [ default: ./merged_asm  ]
    #     -g/--ref-gtf                            An optional "reference" annotation GTF.
    #     -s/--ref-sequence      <seq_dir>/<seq_fasta> Genomic DNA sequences for the reference.
    #     --min-isoform-fraction <0-1.0>          Discard isoforms with abundance below this       [ default:           0.05 ]
    #     -p/--num-threads       <int>            Use this many threads to merge assemblies.       [ default:             1  ]
    #     --keep-tmp                              Keep all intermediate files during merge
    class Merge
      include Bio::Command::Wrapper

      set_program Bio::Ngs::Utils.binary("cuffmerge")

      add_option "output-dir", :type => :string, :aliases => '-o', :default => "merged_asm"
      add_option "ref-gtf", :type => :string, :aliases => '-g'
      add_option "ref-sequence", :type => :string, :aliases => '-s'
      add_option "min-isoform-fraction", :type => :numeric, :aliases => '-m'
      add_option "num-threads", :type => :numeric, :aliases => '-p', :default => 6
      add_option "keep-tmp", :type => :boolean, :aliases => 't'
    end #Merge

    # gffread <input_gff> [-g <genomic_seqs_fasta> | <dir>][-s <seq_info.fsize>]
    #  [-o <outfile.gff>] [-t <tname>] [-r [[<strand>]<chr>:]<start>..<end> [-R]]
    #  [-CTVNJMKQAFGUBHZWTOLE] [-w <exons.fa>] [-x <cds.fa>] [-y <tr_cds.fa>]
    #  [-i <maxintron>]
    #  Filters and/or converts GFF3/GTF2 records.
    #  <input_gff> is a GFF file, use '-' if the GFF records will be given at stdin

    #  Options:
    #   -g  full path to a multi-fasta file with the genomic sequences
    #       for all input mappings, OR a directory with single-fasta files
    #       (one per genomic sequence, with file names matching sequence names)
    #   -s  <seq_info.fsize> is a tab-delimited file providing this info
    #       for each of the mapped sequences:
    #       <seq-name> <seq-length> <seq-description>
    #       (useful for -A option with mRNA/EST/protein mappings)
    #   -i  discard transcripts having an intron larger than <maxintron>
    #   -r  only show transcripts overlapping coordinate range <start>..<end>
    #       (on chromosome/contig <chr>, strand <strand> if provided)
    #   -R  for -r option, discard all transcripts that are not fully
    #       contained within the given range
    #   -U  discard single-exon transcripts
    #   -C  coding only: discard mRNAs that have no CDS feature
    #   -F  full GFF attribute preservation (all attributes are shown)
    #   -G  only parse additional exon attributes from the first exon
    #       and move them to the mRNA level (useful for GTF input)
    #   -A  use the description field from <seq_info.fsize> and add it
    #       as the value for a 'descr' attribute to the GFF record

    #   -O  process also non-transcript GFF records (by default non-transcript
    #       records are ignored)
    #   -V  discard any mRNAs with CDS having in-frame stop codons
    #   -H  for -V option, check and adjust the starting CDS phase
    #       if the original phase leads to a translation with an
    #       in-frame stop codon
    #   -B  for -V option, single-exon transcripts are also checked on the
    #       opposite strand
    #   -N  discard multi-exon mRNAs that have any intron with a non-canonical
    #       splice site consensus (i.e. not GT-AG, GC-AG or AT-AC)
    #   -J  discard any mRNAs that either lack initial START codon
    #       or the terminal STOP codon, or have an in-frame stop codon
    #       (only print mRNAs with a fulll, valid CDS)

    #   -M/--merge : cluster the input transcripts into loci, collapsing matching
    #        transcripts (those with the same exact introns and fully contained)
    #   -d <dupinfo> : for -M option, write collapsing info to file <dupinfo>
    #   --cluster-only: same as --merge but without collapsing matching transcripts
    #   -K  for -M option: also collapse shorter, fully contained transcripts
    #       with fewer introns than the container
    #   -Q  for -M option, remove the containment restriction:
    #       (multi-exon transcripts will be collapsed if just their introns match,
    #       while single-exon transcripts can partially overlap (80%))

    #   -E  expose (warn about) duplicate transcript IDs and other potential
    #       problems with the given GFF/GTF records
    #   -Z  merge close exons into a single exon (for intron size<4)
    #   -w  write a fasta file with spliced exons for each GFF transcript
    #   -x  write a fasta file with spliced CDS for each GFF transcript
    #   -W  for -w and -x options, also write for each fasta record the exon
    #       coordinates projected onto the spliced sequence
    #   -y  write a protein fasta file with the translation of CDS for each record
    #   -L  Ensembl GTF to GFF3 conversion (implies -F; should be used with -m)
    #   -m  <chr_replace> is a reference (genomic) sequence replacement table with
    #       this format:
    #       <original_ref_ID> <new_ref_ID>
    #       GFF records on reference sequences that are not found among the
    #       <original_ref_ID> entries in this file will be filtered out
    #   -o  the "filtered" GFF records will be written to <outfile.gff>
    #       (use -o- for printing to stdout)
    #   -t  use <trackname> in the second column of each GFF output line
    #   -T  -o option will output GTF format instead of GFF3
    class GffRead
      include Bio::Command::Wrapper

      set_program Bio::Ngs::Utils.binary("gffread")
      use_aliases

      add_option "genomic-sequence", :type => :string, :aliases => '-g'
      add_option "seq-info", :type => :string, :aliases => '-s'
      add_option "discard-transcripts", :type => :numeric, :aliases => '-i'
      add_option "orverlap-coords", :type => :string, :aliases => '-r'
      add_option "discard-not-overlap", :type => :string, :aliases => '-R'
      add_option "discard-single-exon", :type => :boolean, :aliases => '-U'
      add_option "coding-only", :type => :boolean, :aliases => '-C'
      add_option "full-attributes", :type => :boolean, :aliases => '-F'
      add_option "partial-attributes", :type => :boolean, :aliases => '-G'
      add_option "description-field", :type => :string, :aliases => '-A'
      add_option "also-non-transcripts", :type => :boolean, :aliases => '-O'
      add_option "discard-in-frame-stop", :type => :boolean, :aliases => '-V'
      add_option "adjust-codon-phase", :type => :boolean, :aliases => '-H'
      add_option "single-exon-check-opposite", :type => :boolean, :aliases => '-B'
      add_option "discard-multi-exon", :type => :boolean, :aliases => '-N'
      add_option "discard-wrong-codon", :type => :boolean, :aliases => '-J'
      add_option "merge", :type => :boolean, :aliases => '-M'
      add_option "output-collapsing", :type => :string, :aliases => '-d'
      add_option "cluster-only", :type => :boolean, :aliases => '-c'
      add_option "collaps-contained", :type => :boolean, :aliases => '-K'
      add_option "remove-containment-restriction", :type => :boolean, :aliases => '-Q'
      add_option "warnings", :type => :boolean, :aliases => '-E'
      add_option "merge-close-exons", :type => :boolean, :aliases => '-Z'
      add_option "write-exon-fasta", :type => :boolean, :aliases => '-w'
      add_option "write-cds-fasta", :type => :boolean, :aliases => '-x'
      add_option "write-coords", :type => :boolean, :aliases => '-W'
      add_option "write-protein-fasta", :type => :boolean, :aliases => '-y'
      add_option "ensembl-to-gff3", :type => :boolean, :aliases => '-L'
      add_option "chr-replace", :type => :string, :aliases => '-m'
      add_option "output", :type => :string, :aliases => '-o', :default => "outfile.gtf", :collapse=>true
      add_option "track-name", :type => :string, :aliases => '-t'
      add_option "output-gtf", :type => :boolean, :aliases => '-T'
    end # GffRead
  end #Cufflinks
end #Ngs
end #Bio
