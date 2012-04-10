class Filter < Thor

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
<<<<<<< HEAD
    list_dictionary = {}#Hash.new {|hash,key| hash[key] = :fool}
=======
    list_dictionary = Hash.new {|hash,key| hash[key] = :fool}
>>>>>>> master

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
<<<<<<< HEAD
    skipped_lines << ftable.readline if options[:skip_table_header]
=======

    skipped_lines << ftable.readline unless options[:skip_table_header]
>>>>>>> master
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
<<<<<<< HEAD
      if list_dictionary.key?(table_key=line.split(delimiter)[table_key_idx]) || options[:exclude]
        fout.puts fuse_lambda.call(line,list_dictionary, table_key)
=======
      #if list_dictionary.key?(line.split(delimiter)[table_key_idx]) || options[:exclude]
      if find_key_in_dictionary(line.split(delimiter)[table_key_idx], list_dictionary, options[:in_column_delimiter]) || options[:exclude]
        fout.puts line
>>>>>>> master
      end
    end
    ftable.close
    fout.close unless options[:output].nil?
  end

  private

  def find_key_in_dictionary(key, dict, split_key=nil)
    if split_key.nil?
      dict.key?(key)
    else
      key.split(split_key).each do |ikey|
        ikey == key && break
      end
    end
  end

end
