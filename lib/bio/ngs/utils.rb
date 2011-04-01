#
#  
#
# Copyright:: Copyright (C) 2011
#     Francesco Strozzi <francesco.strozzi@gmail.com>
#     Raoul J.P. Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#

module Bio
  module Ngs
    class Utils
      
      def self.binary(name)
        path = File.expand_path(File.dirname(__FILE__))
        if File.exists?(plugin_binary = File.join(path,"ext","bin","common",name))
          return plugin_binary
        elsif File.exists?(plugin_os_binary = File.join(path,"ext","bin",self.os_type,name))
          return plugin_os_binary
        elsif (os_binary = Bio::Command.query_command ["which", name]) != ""
          return os_binary.tr("\n","")
        else
          raise ArgumentError, "No binary found with this name: #{name}"
        end  
      end
      
      def self.os_type
        require 'rbconfig'
        case Config::CONFIG['host_os']
          when /darwin/ then return "osx" 
          when /linux/ then return "linux"
          when /mswin|mingw/ then raise NotImplementedError, "This plugin does not run on Windows"
        end
      end
      
      # Remove from filename the dot and the extension, adds the tag and the new extension
      def self.tag_filename(filename, tag, extension)
        if filename=~/\..*/
          filename.gsub(/\..*/, "_#{tag}.#{extension}")
        else
          "#{filename}_#{tag}.#{extension}"
        end
      end #tag_filename
      
      def self.extend_system_path
        path = File.expand_path(File.dirname(__FILE__))
        common_dir= File.join(path,"ext","bin","common")
        os_dir = File.join(path,"ext","bin",self.os_type)
        sub_dirs = Dir[os_dir+"/*"].select do |file|
          File.directory?(file)
        end.map do |dir|
          ":"+dir
        end.join
        ENV["PATH"]+=":"+common_dir+":"+os_dir + sub_dirs
      end #extend_system_path
        
      
    end # end Utils
  end # end NGS
end # end Bio
