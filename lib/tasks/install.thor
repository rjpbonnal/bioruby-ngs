class Install < Thor
	
		
		desc "tools","Download and install NGS tools"
		def tools
			gem_path = File.expand_path(File.join(File.dirname(__FILE__),"..","..","ext"))
			Dir.chdir gem_path
    	load 'mkrf_conf.rb'
    	`rake -f Rakefile`
    	FileUtils.remove("Rakefile")
		end
	
end

