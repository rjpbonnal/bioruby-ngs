#
#  
#
# Copyright:: Copyright (C) 2011
#     Francesco Strozzi <francesco.strozzi@gmail.com>
# License:: The Ruby License
#
#

class Project < Thor
  include Thor::Actions

  def self.source_root
     File.expand_path(File.dirname(__FILE__))
  end
    
  attr_accessor :name
  
  desc "new [NAME]","Create a new NGS project directory"
  method_option :type, :type => :string, :desc => "The project type (e.g. annotation)"
  def new(name)
    empty_directory name
    empty_directory File.join("#{name}","data")
    empty_directory File.join("#{name}","tasks")
    empty_directory File.join("#{name}","scripts")
    self.name = name # for template to take the correct values
    template(File.join("..","templates","README.tt"), "#{name}/README.txt")    
    
    if options[:type] == "annotation"
        invoke "project:update:annotation", [],{:dir => name}
    else    
      empty_directory File.join("#{name}","log")
      empty_directory File.join("#{name}","conf")
    end
  end
  
  class Update < Project
    
    desc "annotation", "Update the working dir to an Annotation project"
    method_option :dir, :type => :string
    def annotation
      dir = (options[:dir]) ? options[:dir]+"/" : ""
      empty_directory "#{dir}log"
      empty_directory "#{dir}conf"
      empty_directory "#{dir}db"
      template(File.join("..","templates/annotation","annotation_db.tt"), "#{dir}conf/annotation_db.yml")
      FileUtils.rm Dir.glob("db/migrate/*.rb")
      template(File.join("..","templates/annotation","create_goannotation.tt"), "#{dir}db/migrate/#{Time.now.strftime("%Y%m%d%M11")}_create_goannotation.rb")
      template(File.join("..","templates/annotation","create_blastout.tt"), "#{dir}db/migrate/#{Time.now.strftime("%Y%m%d%M12")}_create_blastout.rb")
      template(File.join("..","templates/annotation","create_go.tt"), "#{dir}db/migrate/#{Time.now.strftime("%Y%m%d%M13")}_create_go.rb")
      template(File.join("..","templates/annotation","annotation_models.tt"), "#{dir}db/models/annotation_models.rb")
    end
  
  end

  
end
