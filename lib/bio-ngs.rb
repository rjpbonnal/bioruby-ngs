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

if defined?(JRUBY_VERSION)
	require 'jdbc-sqlite3'
else
	require 'sqlite3'
end
#Generic classes
require 'enumerable'
require 'wrapper'
require 'meta'

# NGS classes
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

require 'bio/appl/ngs/cufflinks/iterators'
require 'bio/appl/ngs/cufflinks/gtf/gtf_parser'
require 'bio/appl/ngs/cufflinks/gtf/gtf'
require 'bio/appl/ngs/cufflinks/gtf/transcript'
require 'bio/appl/ngs/cufflinks'
require 'bio/appl/ngs/samtools'
require 'bio/appl/ngs/fastx'
require 'bio/appl/ngs/blast'
require 'bio/appl/ngs/bwa'
require 'bio/appl/ngs/casava'

#Illumina utility for projects
require 'bio/ngs/illumina/illumina'
require 'bio/ngs/fs'

# history
Bio::Ngs::HISTORY_FILE = Dir.pwd+"/.task-history.yml"
Bio::Ngs::Utils.extend_system_path


# loading Tasks
# TODO let the user define which tasks must be loaded, maybe a list of names
if Bio::Ngs.const_defined?(:LoadBaseTasks) && Bio::Ngs.const_get(:LoadBaseTasks)==true
  path = File.expand_path(File.dirname(__FILE__))
  Dir.glob(File.join(path,"tasks","*.thor")) do |thorfile|
    Thor::Util.load_thorfile(thorfile)
  end
end
