module Bio
  module Ngs
    class Db
      
      require 'active_support/inflector'
            
      # Open a connection to a database using ActiveRecord
      def initialize(db_type,yaml_file=Dir.pwd+"/conf/#{db_type}_db.yml")
        @db_type = db_type
        @db = ActiveRecord::Base
        @db.establish_connection YAML.load_file(yaml_file)
        # ONLY FOR DEBUG
        #require 'logger'
        #ActiveRecord::Base.logger = Logger.new 'log/db.log'
        require File.expand_path(File.dirname(__FILE__)+"/db/models/#{@db_type}.rb")
      end
    
      # Runs AR migrations and create database tables
      def create_tables(verbose=false)
        ActiveRecord::Migration.verbose = verbose
        ActiveRecord::Migrator.migrate(File.expand_path(File.dirname(__FILE__)+"/db/migrate/#{@db_type}"),nil)
      end
      
      # Export a database table into a tab-separated file
      def export(table,fileout)
        klass = @db.const_get(table.singularize.camelize)
        columns = klass.column_names
        out = File.open(fileout,"w") 
        out.write columns.join("\t")+"\n"
        klass.find(:all).each do |output|
          records = output.attributes
          values = []
          columns.each {|c| values << records[c]}
          out.write values.join("\t")+"\n"
        end
      end
      
      # Wrapper for DB transaction to execute many INSERT queries into a single transaction
      # This can speed up things espectially for SQLite databases.
      def insert_many(table,query,values=[])
        klass = @db.const_get(table.singularize.camelize)
        klass.transaction do 
          values.each do |v|
            sql = @db.send(:sanitize_sql_array,[query]+v)
            @db.connection.execute(sql)
          end
        end
      end
      
    end
  end
end