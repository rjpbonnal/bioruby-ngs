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
      
      def self.os_binary(name)
        path = File.expand_path(File.dirname(__FILE__))
        os = self.os_type
        File.join(path,"ext","bin",os,name)
      end
      
      def self.binary(name)
        path = File.expand_path(File.dirname(__FILE__))
        File.join(path,"ext","bin","common",name)
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