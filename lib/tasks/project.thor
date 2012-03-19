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
    empty_directory File.join("#{name}","raw_data")
    empty_directory File.join("#{name}","outputs")
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
  
  attr_accessor :type

  desc "update [TYPE]", "Update the working dir to a new type of project"
  method_option :dir, :type => :string
  def update(type)
    self.type = type
    dir = (options[:dir]) ? options[:dir]+"/" : ""
    empty_directory "#{dir}log"
    empty_directory "#{dir}conf"
    empty_directory "#{dir}db"
    template(File.join("..","templates","db.tt"), "#{dir}conf/#{type}_db.yml")
  end

  
end
