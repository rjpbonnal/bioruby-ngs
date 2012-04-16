#TODO: refactor this code, I don't like it very much
#TODO: export in JSON format
module Bio
  module Ngs
    module Illumina

        #TODO does it make sense splitting this generic class in more specific subclasses ?
        class ReadsData
            attr_accessor :name, :left, :right, :index, :zipped, :chunks #, :filtered, :trimmed
            def initialize(name, opts={})
                @name = name
                @left = opts[:left] || false
                @right = opts[:right] || false
                @index = opts[:index]
                @zipped = opts[:zipped] || false
                @chunks = opts[:chunks] || [] #todo, is it a real array ?
                # @filtered = opts[:filtered] || false
                # @trimmed = opts[:trimmed] || false
            end

            def right?
               right==true
            end
            
            def left?
               left==true
            end

            def zipped?
               zipped==true
            end

            def filename_left
              "#{name}_R1_#{chunk}.fastq#{'.gz' if zipped?}" 
            end

            def filename_right
              "#{name}_R2_#{chunk}.fastq#{'.gz' if zipped?}"
            end

            def filename_path(name)
                results=chunks.inject([]) do |results, chunk|
                  results << filename_left  if left?
                  results << filename_right if right?
                end
            end
        end

    	class Sample
    		attr_accessor :name #, :filenames
    		def initialize(name, parent=nil)
    		  @name = name
    		#  @paired = nil
              @raw = nil
              @filtered = []
              @trimmed = []

    		  #@filenames =  Hash.new {|hash,key| hash[key] = {left:false,right:false,index:nil,zipped:false,chunks:[]}} # {name=>{:right=>string, :left=>string, :single=>string, :zipped=>(true|false), :index=>string, :chunk=>(001,002,003,...)}, ...}
    		  @parent = parent
    		end

    		def path
    		  File.join @parent.path,"Sample_#{name}"
    		end

    		def paired?
    		  @filenames.key?(:left) && @filenames.key?(:right)
    		end

    		def add_filename(filename)
               metadata = {}
               #TODO maybe could be usefult to leave this to end used, define what is a filtered/trimmerd file. Define a regexp for each category.
               metadata[:trimmed] = true if filename=~/trimmed/
               metadata[:filtered] = true if filename=~/filtered/
               metadata[:left] = true if filename=~/.*_R1_.*/
               metadata[:right] = true if filename=~/.*_R2_.*/
               metadata[:zipped] = true if filename=~/\.gz/

                   		  #filename_cleaned = filename.sub(/_R.*/,'')
                filename_cleaned = File.basename(filename).sub(/_R.*/,'')

    		  # if filename=~/.*_R1_.*/
        #         @filenames[filename_cleaned][:left]=true
        #       elsif filename=~/.*_R2_.*/
        #     	@filenames[filename_cleaned][:right]=true
        #       end
                	
        #       if filename=~/\.gz/
        #       	@filenames[filename_cleaned][:zipped]=true
        #       # elsif filename=~/\.fastq$/
        #       # 	@filenames[filename_cleaned][:zipped]=false
        #       end

              if filename=~/R._(\d*).fastq(.gz)?/
              	@filenames[filename_cleaned][:chunks]<<$1 unless @filenames[filename_cleaned][:chunks].include?($1)
              end	
    		end

    		# def filename_path(name)
    		#   if @filenames.key?(name)
    		#   	data = @filenames[name]
    		#   	results=data[:chunks].map do |chunk|
    		#   		subdata={}
    		#       subdata[:left]=File.join(path, "#{name}_R1_#{chunk}.fastq" )  if data.key?(:left)
    		#       subdata[:right]=File.join(path, "#{name}_R2_#{chunk}.fastq" )  if data.key?(:right)
    		#       subdata
    		#     end
    		#     if data[:zipped]
    		#       results.each_index do |idx|
    		#         results[idx][:left]="#{results[idx][:left]}.gz" if data.key?(:left)
    		#         results[idx][:right]="#{results[idx][:right]}.gz" if data.key?(:right)
    		#       end
    		#     end
    		#   end
    		# end

    		def filenames_paths
    			@filenames.keys.map do |filename|
    				filename_path(filename)
    			end.flatten
    		end

            def to_json(*a)
              {
                "json_class"   => self.class.name,
                "name"         => name,
                "filenames"    => filenames_paths
               }.to_json(*a)
            end
    	end
    end #Illumina
  end #Ngs
end #Bio	





