#
#  bio-ngs.rb - Mian bio-ngs clas
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>,
#     Francesco Strozzi <francesco.strozzi@gmail.com>
# License:: The Ruby License
#
#


#require 'rubygems'

require 'bio-bwa'
require 'thor'
require 'thor/group'
require 'thor/runner'
require 'bio'
require 'wrapper'
require 'bio/ngs/utils'
require 'bio/ngs/record'
require 'bio/ngs/options'
require 'bio/ngs/quality'
require 'bio/ngs/graphics'
require 'bio/ngs/task'

#tools
require 'bio/appl/ngs/tophat'
require 'bio/appl/ngs/bowtie-inspect'
require 'bio/appl/ngs/sff_extract'

# history 
Bio::Ngs::HISTORY_FILE = ".task-history.yml"




