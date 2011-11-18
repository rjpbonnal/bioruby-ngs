#
#  bio-ngs.rb - Main bio-ngs class
#
# Copyright:: Copyright (C) 2011
#     Raoul Bonnal <r@bioruby.org>,
#     Francesco Strozzi <francesco.strozzi@gmail.com>
# License:: The Ruby License
#
#



# External gems
require 'parallel'
require 'yaml'
require 'json'
require 'daemons'
require 'bio-samtools'
require 'thor'
require 'thor/group'
require 'thor/runner'
require 'bio-blastxmlparser'
require 'bio'
require 'active_record'
require 'sqlite3'

# NGS classes
require 'enumerable'
require 'wrapper'
require 'bio/ngs/utils'
require 'bio/ngs/record'
require 'bio/ngs/quality'
require 'bio/ngs/graphics'
require 'bio/ngs/task'
require 'bio/ngs/core_ext'
require 'bio/ngs/converter'
require 'bio/ngs/db'
require 'bio/ngs/homology'
require 'bio/ngs/ontology'

#tools
require 'bio/appl/ngs/tophat'
require 'bio/appl/ngs/bowtie-inspect'
require 'bio/appl/ngs/sff_extract'
require 'bio/appl/ngs/bcl2qseq' #TODO: FIX THIS BUGGY CODE in THOR TASK

require 'bio/appl/ngs/cufflinks'
require 'bio/appl/ngs/samtools'
require 'bio/appl/ngs/fastx'
require 'bio/appl/ngs/blast'
require 'bio/appl/ngs/bwa'

# history 
Bio::Ngs::HISTORY_FILE = Dir.pwd+"/.task-history.yml"
Bio::Ngs::Utils.extend_system_path

# loading Tasks
path = File.expand_path(File.dirname(__FILE__))
Dir.glob(File.join(path,"tasks","*.thor")) do |thorfile|
  Thor::Util.load_thorfile(thorfile)
end
