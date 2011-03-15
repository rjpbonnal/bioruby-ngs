#
#  
#
# Copyright:: Copyright (C) 2011
#     Francesco Strozzi <francesco.strozzi@gmail.com>
# License:: The Ruby License
#
#

module Bio
  module Ngs
    class Utils
      
      def self.binary(name)
        path = File.expand_path(File.dirname(__FILE__))
        file = File.join(path,"ext","bin","common",name)
        os = self.os_type
        os_file = File.join(path,"ext","bin",os,name)
        if File.exists?(file)
          return file
        elsif File.exists?(os_file)  
          return os_file
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
      
    end # end Utils
  end # end NGS
end # end Bio
