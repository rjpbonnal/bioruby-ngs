class Project < Thor::Group
  include Thor::Actions
  # the project name
  argument :project_name
  
  def self.source_root
     File.expand_path(File.dirname(__FILE__))
  end
  
  def create_project_dir
    empty_directory project_name
  end
  
  def create_sub_dirs
    empty_directory File.join("#{project_name}","data")
    empty_directory File.join("#{project_name}","log")
    empty_directory File.join("#{project_name}","tasks")
    empty_directory File.join("#{project_name}","scripts")
    empty_directory File.join("#{project_name}","conf")
  end
  
  def create_readme
    template(File.join("..","templates","README.erb"), "#{project_name}/README.txt")
  end
  
  
end