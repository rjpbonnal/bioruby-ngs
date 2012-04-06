$TESTING=true

# require 'simplecov'
# SimpleCov.start do
#   add_group 'Libraries', 'lib'
#   add_group 'Specs', 'spec'
# end

require 'thor'
require 'thor/base'
require 'stringio'
require 'rdoc'
require 'rspec'
require 'diff/lcs' # You need diff/lcs installed to run specs (but not to run Thor).
#require 'fakeweb'  # You need fakeweb installed to run specs (but not to run Thor).

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'bio-ngs'

# Set shell to basic
$0 = "thor"
$thor_runner = true
ARGV.clear
Thor::Base.shell = Thor::Shell::Basic

# Load fixtures
%w(bwa history project quality rna sff_extract filter).each do |task|
  load File.join(File.dirname(__FILE__), "..", "lib", "tasks", "#{task}.thor" )
end

RSpec.configure do |config|
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def source_root
    File.join(File.dirname(__FILE__), "..", "lib", "tasks")
  end

  def destination_root
    File.join(File.dirname(__FILE__), 'sandbox')
  end

  alias :silence :capture
end
