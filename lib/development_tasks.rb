class BioNgs
  # Rake tasks inspired by Jeweler approach
  # Include tasks used during gem installation.
  # Why ? If a developer want's to have a ready to go environment
  # with bioinformatics software supported by biongs in it's cloned directory.
  class BioNgsTasks < ::Rake::TaskLib
    attr_accessor :biongs

    def initialize
      yield self if block_given?

      define
    end

    def biongs
      @biongs ||= self
    end

    def define
      namespace :devenv do
        desc "install external bioinformatics tools, for development, locally -in this directory, cloned from github?-"
        task :bio_tools do
          Dir.chdir("ext") do
            load 'mkrf_conf.rb'
            `rake -f Rakefile`
            FileUtils.remove("Rakefile")
          end
        end
      end

      task :devenv => 'devenv:bio_tools'
    end
  end
end