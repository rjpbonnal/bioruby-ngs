#require 'rubygems'
require 'wrapper'

require 'bio-bwa'
require 'thor'
require 'thor/group'
require 'thor/runner'
require 'bio'
require 'bio/ngs/utils'
require 'bio/ngs/record'
require 'bio/ngs/options'
require 'bio/ngs/quality'
require 'bio/ngs/graphics'

#tools
require 'bio/appl/ngs/tophat'

# history 
Bio::Ngs::HISTORY_FILE = ".task-history.yml"




