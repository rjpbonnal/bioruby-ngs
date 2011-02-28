class Project < Thor::Group
  include Thor::Actions
  # the project name
  argument :name
  
  def self.source_root
     File.expand_path(File.dirname(__FILE__))
  end
  
  def create_project_dir
    empty_directory name
  end
  
  def create_sub_dirs
    empty_directory File.join("#{name}","data")
    empty_directory File.join("#{name}","log")
    empty_directory File.join("#{name}","tasks")
    empty_directory File.join("#{name}","scripts")
    empty_directory File.join("#{name}","conf")
  end
  
  def create_readme
    template(File.join("..","templates","README.erb"), "#{name}/README.txt")
  end
  
end