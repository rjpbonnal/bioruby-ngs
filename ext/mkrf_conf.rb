#(c) Copyright 2011 Raoul Bonnal. All Rights Reserved. 

# create Rakefile for shared library compilation


path = File.expand_path(File.dirname(__FILE__))

path_external = File.join(path, "../lib/bio/ngs/ext")
path_binary = File.join(path_external,"bin","common")


File.open(File.join(path,"Rakefile"),"w") do |rakefile|
rakefile.write <<-RAKE
require 'rbconfig'
require 'open-uri'
require 'fileutils'
include FileUtils::Verbose
require 'rake/clean'
require 'yaml'

versions = YAML.load_file(File.join("#{path_external}","versions.yaml"))


task :download do
  versions.each do |tool, info|
    printf "Downloading \#{tool}..."
    file_name = "\#{info["basename"]}\#{info["version"]}.\#{info["suffix"]}"
    url = "\#{info["url"]}\#{file_name}"
    printf url
    open(url) do |uri|
      File.open(file_name,'wb') do |fout|
        fout.write(uri.read)
      end #fout 
    end #uri
    puts " over."
  end #versions
end
    
task :compile do
   versions.each do |tool, info|
     printf "Compiling \#{tool}..."
     tool_file_name = "\#{info["basename"]}\#{info["version"]}.\#{info["suffix"]}"
     tool_dir_name = "\#{info["basename"]}\#{info["version"]}"
     uncompress = case info["suffix"]
                  when "tar.bz2" then "tar xvfj"
                  when "tar.gz" then "tar xvfz"
                  when "zip" then "unzip"
                  else
                    raise "Unkonw suffix for \#{tool}, \#{info.inspect}"
                  end
      system "\#{uncompress} \#{tool_file_name}"
      cd(tool_dir_name) do
        system "PKG_CONFIG_PATH='#{path_external}/bin/common/lib/pkgconfig' ./configure --prefix=#{path_binary} --bindir=#{path_binary}"
        system "make"
        system "make install"
      end #cd
      puts " over."
   end #versions
end
  
task :clean do
  versions.each do |tool, info|
   tool_file_name = "\#{info["basename"]}\#{info["version"]}.\#{info["suffix"]}"
   tool_dir_name = "\#{info["basename"]}\#{info["version"]}"
    puts tool_dir_name
    cd(tool_dir_name) do
      system "make clean"
    end #cd
    rm(tool_file_name)
    rm_rf(tool_dir_name)
  end #versions
end

task :default => [:download, :compile, :clean]
  
RAKE
  
end