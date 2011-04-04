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
      db = ActiveRecord::Base
      db.establish_connection YAML.load_file('conf/annotation_db.yml')
      require Dir.pwd+'/db/models/annotation_models.rb'
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
          sql = db.send(:sanitize_sql_array,["INSERT INTO blast_outputs(query_id,target_id,target_description,evalue,identity,positive) VALUES(?,?,?,?,?,?)",iter.query_def,hit.hit_id,hit.hit_def,evalue,identity,positive])
          inserts << sql
          BlastOutput.transaction {inserts.each {|i| db.connection.execute(i)}; inserts = []} if inserts.size == 1000
        end
      end
      BlastOutput.transaction {inserts.each {|i| db.connection.execute(i)}} if inserts.size > 0
    end
    
    desc "export [TABLE]","Export the data from a table to a tab-separated file"
    method_option :fileout, :type => :string, :desc => "file used to save the output"
    def export(table)
      db = ActiveRecord::Base
      db.establish_connection YAML.load_file('conf/annotation_db.yml')
      require Dir.pwd+'/db/models/annotation_models.rb'
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
    
  end
  
  
  class Download < Annotation

    desc "uniprot","Download the Uniprot-SwissProt file from UniprotKB"
    def uniprot
      download_and_uncompress("ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz","data/uniprot_sprot.fasta.gz","b")
    end
    
    desc "ontology","Download the Uniprot GeneOntology file"
    def ontology
      download_and_uncompress("http://cvsweb.geneontology.org/cgi-bin/cvsweb.cgi/go/gene-associations/gene_association.goa_uniprot_noiea.gz?rev=HEAD","data/goa_uniprot.gz","b")
    end
    
    desc "all", "Download the Uniprot-Swissprot and Uniprot GO Annotation files"
    def all
      invoke :uniprot
      invoke :ontology
    end
    
    private
    
    def download_and_uncompress(url,fileout,mode)
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

end