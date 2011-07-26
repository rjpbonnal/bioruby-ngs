#(c) Copyright 2011 Raoul Bonnal. All Rights Reserved. 

# create Rakefile for shared library compilation


path = File.expand_path(File.dirname(__FILE__))

path_external = File.join(path, "../lib/bio/ngs/ext")
path_lib = File.join(path,"../lib")
path_binary = File.join(path_external,"bin","common")


  File.open(File.join(path,"Rakefile"),"w") do |rakefile|
    if (ARGV.include?("--biolinux") | ARGV.include?("--no-third-party"))
      rakefile.write <<-RAKE
      task :default do
        puts "Nothing to do, third party software must be, already, installed on the host system. Bye Bye!"
      end #default
      RAKE
    else
    rakefile.write <<-RAKE

    require 'rbconfig'
    require 'open-uri'
    require 'fileutils'
    include FileUtils::Verbose
    require 'rake/clean'
    require 'yaml'
    require File.join("#{path_lib}","/bio/ngs/utils") #ToDo: I dnk if it is better to require everything or just the utils Bio::Ngs::Utils

    module Gem
      module Install
        class << self
          def foreign_files(path=".")
            install_files = %w(Rakefile gem_make.out mkrf_conf.rb).map{|fn| File.join(path,fn)}
            Dir.glob(path+"/*") - install_files
          end
        end
      end
    end

    versions = YAML.load_file(File.join("#{path_external}","versions.yaml"))


    task :download do

      ["common", Bio::Ngs::Utils.os_type].each do |kind_software|
        #download common libraries or tools
        #download specific OS binaries or libraries    
        versions[kind_software].each do |tool, info|
          filename = "\#{info["basename"]}.\#{info["suffix"]}"
          Bio::Ngs::Utils.download_with_progress(:url => info["url"], :filename => filename)
        end
      end
    end

    task :compile do
      ["common", Bio::Ngs::Utils.os_type].each do |kind_software|
        path_binary = File.join("#{path_external}", 'bin', kind_software)
        #download common libraries or tools
        #download specific OS binaries or libraries    
        versions[kind_software].each do |tool, info|
          Bio::Ngs::Utils.compile_source(tool, info, "#{path_external}", path_binary) if info["type"]=="source"
        end #versions
      end   
    end #compile

    task :binary do
      ["common", Bio::Ngs::Utils.os_type].each do |kind_software|
        path_binary = File.join("#{path_external}", 'bin', kind_software)
        versions[kind_software].each do |tool, info|
          Bio::Ngs::Utils.install_binary(tool, info, "#{path_external}", path_binary) if info["type"]=="binary"
        end #versions
      end   
    end #binary

    task :clean do
      Gem::Install.foreign_files("#{path}").each do |file_to_remove|
        Dir.exists?(file_to_remove) ? FileUtils.remove_dir(file_to_remove) : FileUtils.rm(file_to_remove)
      end
    end #clean

    task :default => [:download,:compile,:binary,:clean]

    RAKE
   end #unless
  end  #file
