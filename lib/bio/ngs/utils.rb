#
#  
#
# Copyright:: Copyright (C) 2011
#     Francesco Strozzi <francesco.strozzi@gmail.com>
#     Raoul J.P. Bonnal <r@bioruby.org>
# License:: The Ruby License
#
#
require 'find'

module Bio
  module Ngs
    class Utils
      class BinaryNotFound < StandardError
        def initialize(opts={})
          @skip_task = opts[:skip_task]
        end

        def skip_task?
          @skip_task
        end
      end
      class << self
        
        def parallel_exec(command_blocks)
          command_blocks.each do |block|
            fork(&block)
          end
          Process.waitall
        end
        
        def binary(name)
          begin
            if !(plugin_binaries_found = find_binary_files(name)).empty?
              return plugin_binaries_found.first
            elsif (os_binary = Bio::Command.query_command ["which", name]) != ""
              return os_binary.tr("\n","")
            else
              raise BinaryNotFound.new(:skip_task=>true), "No binary found with this name: #{name}"
            end
          rescue BinaryNotFound => e
            warn e.message
          end

        end #binary

        def os_type
          require 'rbconfig'
          case Config::CONFIG['host_os']
          when /darwin/ then return "osx" 
          when /linux/ then return "linux"
          when /mswin|mingw/ then raise NotImplementedError, "This plugin does not run on Windows"
          end
        end

        # Remove from filename the dot and the extension, adds the tag and the new extension
        def tag_filename(filename, tag, extension)
          if filename=~/\..*/
            filename.gsub(/\..*/, "_#{tag}.#{extension}")
          else
            "#{filename}_#{tag}.#{extension}"
          end
        end #tag_filename

        def extend_system_path
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

        def download_with_progress(opts = {:url => nil, :mode => "", :filename => nil})
          require "open-uri"
          require "progressbar"
          puts "Downloading from #{opts[:url]}"
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
              puts "\nDone"     
            end

            def uncompress_gz_file(file_in)
              require 'zlib'
              puts "Uncompressing file #{file_in}"
              file_out = file_in.gsub(/.gz/,"") 
              Zlib::GzipReader.open(file_in) {|gz|
                open(file_out,"w") do |file|
                  file.write gz.read
                end
              }
              puts "Done\n"          
            end


            def download_and_uncompress(url,fileout)
              self.download_with_progress(:url => url,:mode => "b",:filename => fileout)
              self.uncompress_gz_file(fileout)
            end       

            def uncompress_command(suffix)
              case suffix
              when "tar.bz2" then "tar xvfj"
              when "tar.gz" then "tar xvfz"
              when "zip" then "unzip"
              else
                raise "Unkonw suffix."
              end
            end #uncompress_command
            
            def uncompress_any(tool_name, tool_record)
              tool_file_name = "#{tool_record["basename"]}.#{tool_record["suffix"]}"
              tool_dir_name = tool_record["basename"]
              uncompress = uncompress_command(tool_record["suffix"])
              STDERR.puts "#{uncompress} #{tool_file_name}"
              system "#{uncompress} #{tool_file_name}"
              STDERR.puts "completed."
              if Dir.exists?(tool_dir_name)
                tool_dir_name
              elsif Dir.exists?("#{tool_name}-#{tool_record['version']}")
                "#{tool_name}-#{tool_record['version']}"
              else
                raise "BioNGS can not identify the uncompressed destination folder"
              end
            end  #uncompress
            
            def compile_source(tool_name, tool_record, path_external, path_binary)
              puts "Uncompressing #{tool_name}..."
              tool_dir_name = uncompress_any(tool_name, tool_record)
              puts "Compiling #{tool_name}..."
              cd(tool_dir_name) do
                #system "#{tool_record["lib"]}='#{path_external}/bin/common/lib'" if tool_record["lib"]
                #system "#{tool_record["flags"]}='-O2'" if tool_record["flags"]
                system "PKG_CONFIG_PATH='#{path_external}/bin/common/lib/pkgconfig' ./configure --prefix=#{path_binary} --bindir=#{path_binary}"
                system "make"
                system "make install"
              end #cd
            end #uncompress_compile
            
            def install_binary(tool_name, tool_record, path_external, path_binary)
              require 'fileutils'
              include FileUtils::Verbose
              puts "Uncompressing #{tool_name}"
              uncompressed_tool_dir_name = uncompress_any(tool_name, tool_record)
              puts "Installing #{tool_name}"
              path_binary_tool = File.join(path_binary,tool_name)
              FileUtils.remove_dir(path_binary_tool) if Dir.exists?(path_binary_tool)
              FileUtils.mkdir(path_binary_tool) 
              FileUtils.cp_r "#{uncompressed_tool_dir_name}/.", path_binary_tool, :preserve=>true
            end #uncompress install binary
            

            # search in the current gem's directory for installed binaries which the name binary_name
            # it's a recursive search in common and os specific directories
            # return an array: empty if the binary can not be found otherwise full path to the binaries
            # it is up to the user choose which binary to use, it's suggested to use the first in the array
            # to have a behavirou similar to the search PATH
            def find_binary_files(binary_name)
              path = File.expand_path(File.dirname(__FILE__))
              Find.find(File.join(path,"ext","bin","common"),File.join(path,"ext","bin",self.os_type)).select do |f|
                File.file?(f) && File.basename(f) == binary_name
              end
            end #find_binary_file
              
          end #eiginclass

        end # end Utils
      end # end NGS
    end # end Bio