source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

gem "bio", ">= 1.4.2"
gem "bio-samtools", ">= 0.3.2"
gem "thor", "= 0.14.6"
gem "rubyvis", ">= 0.5.0"
gem "daemons", ">= 1.1.0"
gem "ruby-ensembl-api", ">= 1.0.1"
gem "activerecord",">= 3.0.5"
gem "progressbar",">= 0.9.0"
gem "rake"
gem "json"
gem "parallel"
gem "bio-blastxmlparser"
  platforms :jruby do
    gem 'jdbc-sqlite3', :require => true 
    gem "activerecord-jdbcsqlite3-adapter"
  end
  platforms :ruby do
    gem 'sqlite3', :require => 'sqlite3'
  end


# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem "shoulda", ">= 0"
  gem "bundler", "~> 1.3.0"
  gem "jeweler", "~> 1.8.4", :git => 'https://github.com/technicalpickles/jeweler.git'
#  gem "rcov", "~> 0.9.11"
  gem "bio", ">= 1.4.2"
  
  platforms :jruby do
    gem 'jdbc-sqlite3', :require => true 
  	gem "activerecord-jdbcsqlite3-adapter"
	end
  platforms :ruby do
    gem 'sqlite3', :require => 'sqlite3'
  end

	gem "thor", "= 0.14.6"
  gem "ffi", ">= 1.0.6"
  gem "rubyvis", ">= 0.5.0"
  gem "rspec", ">= 2.5.0"
  gem "daemons", ">= 1.1.0"
  gem "bio-samtools", ">= 0.3.2"
  gem "ruby-ensembl-api", ">= 1.0.1"
  gem "activerecord",">= 3.0.5"
  gem "progressbar",">= 0.9.0"
  gem "json"
  gem "rake"
  gem "parallel"
	gem "bio-blastxmlparser"
end
