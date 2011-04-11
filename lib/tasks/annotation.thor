class Annotation < Thor

  class Db < Annotation
  
    desc "init", "Initialize Annotation DB"
    def init
      if Dir.exists?("db/migrate") and File.exists?("conf/annotation_db.yml") and Dir.exists?("log")
        ActiveRecord::Base.establish_connection YAML.load_file('conf/annotation_db.yml')
        ActiveRecord::Migration.verbose = true
        ActiveRecord::Migrator.migrate('db/migrate',nil)
      else
        puts "No db, conf and log directories found! Please run 'biongs project:update:annotation'"
        exit
      end
    end
    
  end


  class Data < Annotation
    
    desc "blast [FILE]","Parse Blast XML output and load the results into Annotation DB"
    def blast(file)      
      db = db_connect
      inserts = []
      Bio::Blast::XmlIterator.new(file).to_enum.each do |iter|
        iter.each do |hit|
          identity = []
          positive = []
          evalue = []
          hit.each do |hsp|
            identity << (hsp.identity.to_f/hsp.align_len)*100
            positive << (hsp.positive.to_f/hsp.align_len)*100
            evalue << hsp.evalue
          end
          identity = identity.inject{ |sum, el| sum + el }.to_f / identity.size
          positive = positive.inject{ |sum, el| sum + el }.to_f / positive.size
          evalue = evalue.inject{ |sum, el| sum + el }.to_f / evalue.size
          sql = db.send(:sanitize_sql_array,["INSERT INTO blast_outputs(query_id,target_id,target_description,evalue,identity,positive) VALUES(?,?,?,?,?,?)",iter.query_def,hit.hit_id.split("|")[1],hit.hit_def,evalue,identity,positive])
          inserts << sql
          BlastOutput.transaction {inserts.each {|i| db.connection.execute(i)}; inserts = []} if inserts.size == 1000
        end
      end
      BlastOutput.transaction {inserts.each {|i| db.connection.execute(i)}} if inserts.size > 0
      puts "Parising completed. All the data are now stored into the db.\n"
    end
    
    desc "export [TABLE]","Export the data from a table to a tab-separated file"
    method_option :fileout, :type => :string, :desc => "file used to save the output"
    def export(table)
      db = db_connect
      require 'active_support/inflector'
      klass = db.const_get(table.singularize.camelize)
      columns = klass.column_names
      if options[:fileout]
        out = File.open(options[:fileout],"w")
        out.write columns.join("\t")+"\n"
      else
        puts columns.join("\t")
      end
      
      klass.find(:all).each do |output|
        records = output.attributes
        values = []
        columns.each {|c| values << records[c]}
        if options[:fileout]
          out.write values.join("\t")+"\n"
        else
          puts values.join("\t")
        end
      end
    end
    
    desc "goa","Import GO Annotations file for Uniprot into the db"
    method_option :file, :type => :string, :default => "data/goa_uniprot"
    def goannotation
      db = db_connect
      inserts = []
      File.open(options[:file]).each do |line|
        next if line.start_with? "!"
        line.chomp!
        data = line.split("\t")
        sql = db.send(:sanitize_sql_array,["INSERT INTO go_annotations(db,entry_id,symbol,qualifier,go_id,db_ref,evidence,additional_identifier,aspect,name,synonym,molecule_type,taxon_id,date,assigned_by) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",data[0],data[1],data[2],data[3],data[4],data[5],data[6],data[7],data[8],data[9],data[10],data[11],data[12],data[13],data[14]])
        inserts << sql
        GoAnnotation.transaction {inserts.each {|i| db.connection.execute(i)}; inserts = []} if inserts.size == 1000
      end
      GoAnnotation.transaction {inserts.each {|i| db.connection.execute(i)}} if inserts.size > 0
      puts "Import completed.\n"
    end
    
    desc "go [FILE]", "Import GO definition file"
    def go(file)
      db = db_connect
      inserts = []
      data = []
      file = File.open(file)
      file.each do |line|
        if line.start_with? "[Term]"
          block = file.gets("\n\n")
          block.split("\n").each do |elem|
            if elem.start_with? "id: "
              data << elem.gsub("id: ","")
            elsif elem.start_with? "name: "
              data << elem.gsub("name: ","")
            elsif elem.start_with? "is_a"
              data << elem.gsub("is_a: ","").split("!").first
            elsif elem.start_with? "namespace: "
              data << elem.gsub("namespace: ","")
            end
          end
          sql = db.send(:sanitize_sql_array,["INSERT INTO go(go_id,name,namespace,is_a) VALUES(?,?,?,?)",data[0],data[1],data[2],data[3..-1].join(" ")])
          inserts << sql
          Go.transaction {inserts.each {|i| db.connection.execute(i)}; inserts = []} if inserts.size == 1000 
          data = [] 
        end
      end
      Go.transaction {inserts.each {|i| db.connection.execute(i)}} if inserts.size > 0  
      puts "Import completed.\n"      
    end
    
    
  end
  
  class Report < Annotation
    
    desc "go","Output a graphical report on the GO for the sequences annotated in the db"
    def go
      db = db_connect
      dataset = Hash.new()
      BlastOutput.find(:all).each do |bo|
        bo.go_annotations.each do |go_ann|
          if (go = go_ann.go)
            dataset[go.namespace] = Hash.new(0) unless dataset.has_key? go.namespace
            dataset[go.namespace][go.name] += 1
          end
        end
      end
      dataset.each_pair do |namespace,ontologies|
        ontologies = ontologies.sort {|a,b| b[1] <=> a[1]}
        ontologies.flatten!
        Bio::Ngs::Graphics.bubble_chart(namespace+"_go.svg",Hash[*ontologies[0..39]])
      end
    end
    
    def blast
      
    end
    
  end
  
  
  class Download < Annotation

    desc "uniprot","Download the Uniprot-SwissProt file from UniprotKB"
    def uniprot
      download_and_uncompress("ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz","data/uniprot_sprot.fasta.gz")
    end
    
    desc "goannotation","Download the Uniprot GeneOntology Annotation file"
    def goannotation
      download_and_uncompress("http://cvsweb.geneontology.org/cgi-bin/cvsweb.cgi/go/gene-associations/gene_association.goa_uniprot_noiea.gz?rev=HEAD","data/goa_uniprot.gz")
    end
    
    desc "goslim", "Download the Uniprot GeneOntology Slim file"
    def goslim
      puts "Downloading from http://www.geneontology.org/ontology/obo_format_1_2/gene_ontology.1_2.obo"
      Bio::Ngs::Utils.download_with_progress(:url => "http://www.geneontology.org/ontology/obo_format_1_2/gene_ontology.1_2.obo", :filename => "data/gene_ontology.1_2.obo")
      puts "\nDone."
    end
    
    desc "go", "Download the Uniprot GeneOntology Slim file"
    def go
      puts "Downloading from http://www.geneontology.org/GO_slims/goslim_goa.obo"
      Bio::Ngs::Utils.download_with_progress(:url => "http://www.geneontology.org/GO_slims/goslim_goa.obo", :filename => "data/goslim_goa.obo")
      puts "\nDone."
    end
    
    desc "all", "Download the Uniprot-Swissprot and Uniprot GO Annotation files"
    def all
      invoke :uniprot
      invoke :goa
      invoke :goslim
    end
    
    private
    
    def download_and_uncompress(url,fileout)
      unless Dir.exists? "data"
        puts "No data/ directory found, please run 'biongs annotation:update or create a new project with 'biongs project NAME --type annotation'"
        exit
      end
      puts "Downloading from #{url}"
      Bio::Ngs::Utils.download_with_progress(:url => url,:mode => "b",:filename => fileout)
      puts "\nDone"
      puts "Uncompressing file..."
      Bio::Ngs::Utils.uncompress_gz_file(fileout)
      puts "Done\n"
    end
    
  end


protected

  def db_connect
    db = ActiveRecord::Base
    db.establish_connection YAML.load_file('conf/annotation_db.yml')
    require Dir.pwd+'/db/models/annotation_models.rb'
    # ONLY FOR DEBUG
    #require 'logger'
    #ActiveRecord::Base.logger = Logger.new 'log/db.log' 
    return db
  end

end