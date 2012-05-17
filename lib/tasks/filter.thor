require File.expand_path(File.dirname(__FILE__) + '/../bio/ngs/utils')
require File.expand_path(File.dirname(__FILE__) + '/../wrapper')
require File.expand_path(File.dirname(__FILE__) + '/../bio/appl/ngs/cufflinks')
class Filter < Thor

class Cufflinks < Thor
   #TODO method_option :ucsc, :type => :boolean,        :aliases => '-u', :desc => "use chr as UCSC a prefix for chromosomes, otherwise uses ENSEMBL notation without chr"

   desc "transcripts [GTF]", "Extract transcripts from Cufflinks' GTF"
   method_option :brand_new, :type => :boolean,   :aliases => '-b', :desc => "get only brand new transcripts, no overlap with any annotation feature"
   method_option :new, :type => :boolean,         :aliases => '-n', :desc => "get only new transcripts, overlapping annotations are accepted"
   method_option :annotated, :type => :boolean,   :aliases => '-a', :desc => "get only annotated transcripts"
   method_option :mono_exon, :type => :boolean,   :aliases => '-s', :desc => "get mono exon transcripts"
   method_option :multi_exons, :type => :boolean, :aliases => '-m', :desc => "get multi exons transcripts"
   method_option :length, :type => :numeric,      :aliases => '-l', :desc => "transcripts with a length gt"
   method_option :coverage, :type => :numeric,    :aliases => '-c', :desc => "transcripts with a coverage gt"
   method_option :bed, :type => :boolean,         :aliases => '-t', :desc => "output data in bed format"
   method_option :count, :type => :boolean,       :aliases => '-x', :desc => "counts the selected transcripts"
   method_option :discover, :type => :boolean,    :aliases => '-d', :desc => "discovers transcripts.gtf files from within the current directory"
   method_option :split, :type => :boolean,       :aliases => '-j', :desc => "split each transcript in a file"
   method_option :output, :type => :string,       :aliases => '-o', :desc => "save the results in the output file"
   def transcripts(gtf=nil)
    if gtf.nil? && options[:discover]
      options.remove(:discover)
      Dir.glob("**/transcripts.gtf").each do |gtf_file|
        transcripts(gtf_file)
      end
    elsif !gtf.nil? && File.exists?(gtf)
      data = Bio::Ngs::Cufflinks::Gtf.new gtf
      data.set_lazy
      data.brand_new_isoforms if options[:brand_new]
      data.new_isoforms if options[:new]
      data.annotated_isoforms if options[:annotated]
      data.mono_exons if options[:mono_exons]
      data.multi_exons if options[:multi_exons]
      data.length_gt(options[:length]) if options[:length]
      data.coverage_gt(options[:coverage]) if options[:coverage]

      default_stdout = (options[:output] && File.open(options[:output], 'w')) || $stdout

      if options[:bed] && options[:split]
        data.to_bed do |t, bed_exons| 
          File.open(t.attributes[:transcript_id], 'w') do |w|
          w.puts bed_exons
          end
        end
      elsif options[:bed]
        data.to_bed do |t, bed_exons|
          default_stdout.puts bed_exons
        end          
      elsif options[:count]
        default_stdout.puts "#{gtf}:\t#{data.count}"
      else
        if options[:output]
          data.save(options[:output])
        else
          data.each_transcript do |t|
            default_stdout.puts t
          end
        end
      end
    else
      raise ArgumentError, "file #{gtf} doesn't exist"
    end
   end

   desc "tra_at_idx GTF IDX", "Extract transcripts from Cufflinks' GTF at specific location, print filename in output"
   method_option :split, :type => :boolean,       :aliases => '-j', :desc => "split each transcript in a file"
   method_option :extract, :type => :numeric,     :aliases => '-e', :desc => "extract the n-th transcript"
   method_option :ucsc, :type => :boolean,        :aliases => '-u', :desc => "use chr as UCSC a prefix for chromosomes, otherwise uses ENSEMBL notation without chr"
   method_option :exons, :type => :boolean,       :aliases => '-x', :desc => "proved in output only exons without transcripts", :default => true
   def tra_at_idx(gtf, idx)
      data = Bio::Ngs::Cufflinks::Gtf.new gtf
      t=data[idx.to_i]
      if options[:ucsc]
        t.set_ucsc_notation
      end
      fn = "#{t.attributes[:gene_id]}-#{t.attributes[:transcript_id]}.bed"
      File.open(fn, 'w') do |f|
        f.puts t.to_bed(options[:exons]) #by default only the exons
      end
      puts fn
   end

end #Cufflinks


  # Assume that this is a plain list of elements, with just one column. In the future it could be
  # a table as well.
  desc "by_list TABLE LIST", "Extract from TABLE the row with a key in LIST"
  method_option :exclude, :type => :boolean,                               :aliases => '-e', :desc => "return the elements in TABLE which are not listed in LIST"
  method_option :tablekey, :type => :numeric,                              :aliases => '-k', :desc =>"which field is the key to consider, start from 0"
  method_option :listkey, :type => :numeric,                               :aliases => '-l', :desc =>"which field is the key to consider, start from 0"
  method_option :delimiter, :type => :string, :default => " ",             :aliases => '-d'
  method_option :skip_table_header, :type => :boolean, :default => true,   :aliases => '-h', :desc => 'Skip first line, usually the header'
  method_option :skip_list_header, :type => :boolean, :default => true,    :aliases => '-j', :desc => 'Skip first line, usually the header'
  method_option :skip_table_lines, :type => :numeric,                      :aliases => '-n', :desc => 'Skip Ns line before start'
  method_option :skip_list_lines, :type => :numeric,                       :aliases => '-m', :desc => 'Skip Ns line before start'
  method_option :output, :type => :string,                                 :aliases => '-o', :desc => 'Output results to file'
  method_option :keep_skipped_lines, :type => :boolean, :default => false, :aliases => '-g', :desc => 'Write on output skipped lines from the TABLE file, header and number of lines skipped using option skip_table_line'
  method_option :zero_index_system, :type => :boolean, :default => true,   :aliases => '-s', :desc => 'Starts Index from ZERO ? Otherwise starts from ONE'
  method_option :fuse, :type => :boolean, :default => false,               :aliases => '-f', :desc => 'JOIN two input file using a specific key'
  method_option :in_column_delimiter, :type => :string,                    :aliases => '-i', :desc => 'Define a delimiter for table key, if setted we assume to split the key columns by this separator'
  def by_list(table, list)
  	 unless File.exists?(table)
  	 	STDERR.puts "by_list: #{table} does not exist."
  	 	return
  	 end
  	unless File.exists?(list) 
  		STDERR.puts "by_list: #{list} does not exist."
  		return 
  	end
    table_key_idx = options[:tablekey]  || 0 # by default the first element of the table.
    list_key_idx = options[:listkey] || 0
    fuse = options[:fuse] || false
    #increment indexes in case user wants to start from 1 and not from 0
    #TODO: fix not increment but decrement, user will pass a +1 value
    unless options[:zero_index_system]
      table_key_idx+=1
      list_key_idx+=1
    end
    delimiter = options[:delimiter] || " " # useless it's by default a space, just for developers
    keep_skipped_lines  = options[:keep_skipped_lines] || false
    
    flist = File.open(list, 'r')
    #skip header/lines if required
    if (nlines = options[:skip_list_lines])
      nlines.times.each{|i| flist.readline}
    end
    flist.readline if options[:skip_list_header]
    list_dictionary = Hash.new {|hash,key| hash[key] = :fool}

    #TODO: refactor, find a smarter way to distinguish between fuse or not
    if fuse
      flist.each_line do |line|
        #split row
        #store the list key
        #populate an hash wich keys 
        list_line = line.split(delimiter)
        #save the line but remove the key
        list_key = list_line[list_key_idx]
        list_line.delete_at(list_key_idx)
        list_dictionary[list_key]=list_line
      end      
    else
      flist.each_line do |line|
    	  #split row
    	  #store the list key
    	  #populate an hash wich keys 
        list_dictionary[line.split(delimiter)[list_key_idx]]=:fool
      end
    end
    flist.close

    ftable = File.open(table, 'r')
    #skip header/lines if required
    #keep skipped line in case it's a proprietary format 
    skipped_lines = []
    if (nlines = options[:skip_table_lines])
      nlines.times.each{|i| skipped_lines << ftable.readline}
    end

    skipped_lines << ftable.readline if options[:skip_table_header]

    #list_dictionary = Hash.new {|hash,key| hash[key] = :fool}

    fout = (output_name=options[:output]).nil? ? $stdout : File.open(output_name,'w')
    fout.puts skipped_lines if keep_skipped_lines

    fuse_lambda = if fuse
                    lambda {|table_line, list_dict, key| "#{table_line.chomp}#{delimiter}#{list_dict[key].join(delimiter)}" }
                    #don't know if need to chomp
                  else
                    lambda {|table_line, list_dict, key| table_line}
                  end
    ftable.each_line do |line|
      #search for a key in the dictionary/list 
      #if list_dictionary.key?(line.split(delimiter)[table_key_idx]) || options[:exclude]
      if find_key_in_dictionary(line.split(delimiter)[table_key_idx], list_dictionary, options[:in_column_delimiter]) || options[:exclude]
        fout.puts line
      end
    end
    ftable.close
    fout.close unless options[:output].nil?
  end



  private

  def find_key_in_dictionary(key, dict, split_key=nil)
    #puts dict
    if split_key.nil?
      if dict.key?(key)
        return true
      end
    else
      key.split(split_key).each do |ikey|
        if dict.key?(ikey)
          return true
        end
      end
    end
    return false
  end




end
