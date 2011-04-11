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
      
      def self.download_with_progress(opts = {:url => nil, :mode => "", :filename => nil})
        require "open-uri"
        require "progressbar"
        filename = (opts[:filename]) ? opts[:filename] : opts[:url].split('/')[-1]
        mode = (opts[:mode]) ? opts[:mode] : ""
        pbar = nil
        open(opts[:url],"r"+mode,
            :content_length_proc => lambda {|t|
               if t && 0 < t
                 pbar = ProgressBar.new('', t)
                 pbar.file_transfer_mode
               end
             },
             :progress_proc => lambda {|s|
               pbar.set s if pbar
             }) do |remote|
                open(filename,"w"+mode) {|file| file.write remote.read(16384) until remote.eof?}
             end
      end
      
      def self.uncompress_gz_file(file_in)
        require 'zlib'
        file_out = file_in.gsub(/.gz/,"") 
        Zlib::GzipReader.open(file_in) {|gz|
            open(file_out,"w") do |file|
              file.write gz.read
            end
          }
      end     
      
    end # end Utils
  end # end NGS
end # end Bio
