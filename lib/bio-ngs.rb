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
require 'yaml'
require 'daemons'

# External gems
require 'thor'
require 'thor/group'
require 'thor/runner'
require 'bio-blastxmlparser'
require 'bio'
require 'bio-bwa'
require 'active_record'
require 'sqlite3'

# NGS classes
require 'wrapper'
require 'bio/ngs/utils'
require 'bio/ngs/record'
require 'bio/ngs/quality'
require 'bio/ngs/graphics'
require 'bio/ngs/task'
require 'bio/ngs/core_ext'
require 'bio/ngs/converter'

#tools
require 'bio/appl/ngs/tophat'
require 'bio/appl/ngs/bowtie-inspect'
require 'bio/appl/ngs/sff_extract'
require 'bio/appl/ngs/bcl2qseq' #TODO: FIX THIS BUGGY CODE in THOR TASK
require 'bio/appl/ngs/blast'

# history 
Bio::Ngs::HISTORY_FILE = Dir.pwd+"/.task-history.yml"