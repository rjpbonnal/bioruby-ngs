require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'thor/base'
require 'meta'

describe do
  context Meta::File do

    mf = Meta::File.new('filename.rb', {type:'generic', user:'duck', group:'workers'})

    it 'has name' do
      mf.name.should == 'filename.rb'
    end #name

    it 'has tags' do
      mf.metadata.should == {type:'generic', user:'duck', group:'workers'}
    end #name

  end #File



  describe Meta::Pool do
    before(:each) do
      @mf = Meta::File.new('filename.rb', {type:'generic', user:'duck', group:'workers'})
      @mp = Meta::Pool.new(:my_pool)
    end

    describe "instance variables" do
    it 'has name' do
      @mp.name.should == :my_pool
    end

    it 'has a pool' do
      @mp.pool.should_not be nil
    end
  end

  describe "#add" do
    it 'adds a file to the pool' do
      @mp.add @mf
      @mp.pool.first[1].should == Meta::File.new("filename.rb", {:type=>"generic", :user=>"duck", :group=>"workers"})
    end
  end

  describe '#get_by_name' do
    it do
      @mp.add @mf
      @mp.get_by_name('filename.rb').should == Meta::File.new("filename.rb", {:type=>"generic", :user=>"duck", :group=>"workers"})
    end
  end

  describe '#get_by_tag' do
    it do
      @mp.add @mf      
      @mp.add Meta::File.new('filename_spec.rb', {type:'spec', user:'donald', group:'workers'})
      @mp.get(:type).should == [ Meta::File.new('filename.rb', {type:'generic', user:'duck', group:'workers'}), Meta::File.new('filename_spec.rb', {type:'spec', user:'donald', group:'workers'})]
    end
  end

  describe '#get_by_tag_and_value' do
    it do
      @mp.add @mf      
      @mp.add Meta::File.new('filename_spec.rb', {type:'spec', user:'donald', group:'workers'})
      @mp.get_by_tag_and_value(:group, "workers").should == [ Meta::File.new('filename.rb', {type:'generic', user:'duck', group:'workers'}), Meta::File.new('filename_spec.rb', {type:'spec', user:'donald', group:'workers'})]      
    end
  end


  describe "#get" do
    before(:each) do
      @mp.add @mf
    end
    it 'looks for name' do
      @mp.add Meta::File.new('filename_spec.rb', {type:'spec', user:'donald', group:'workers'})
      @mp.get('filename.rb').should == Meta::File.new('filename.rb', {type:'generic', user:'duck', group:'workers'})
    end
    it 'looks for tag' do
      @mp.add Meta::File.new('filename_spec.rb', {type:'spec', user:'donald', group:'workers', size:10})
      @mp.get(:size).should == Meta::File.new('filename_spec.rb', {type:'spec', user:'donald', group:'workers', size:10})
    end
    it 'looks for value' do
      @mp.add Meta::File.new('filename_spec.rb', {type:'spec', user:'donald', group:'workers'})
      @mp.get("workers").should == [ Meta::File.new('filename.rb', {type:'generic', user:'duck', group:'workers'}),
      Meta::File.new('filename_spec.rb', {type:'spec', user:'donald', group:'workers'})]
    end
  end


  describe "#get_by_value" do
    before(:each) do
      @mp.add @mf
    end
    it 'gets only one file' do
      mft = Meta::File.new('filename_spec.rb', {type:'spec', user:'donald', group:'workers'})
      @mp.add mft
      @mp.get_by_value("donald").should == mft
    end

    it 'gets multiple files' do
      mft = Meta::File.new('filename_spec.rb', {type:'spec', user:'donald', group:'workers'})
      @mp.add mft
      @mp.get_by_value("workers").should == [ Meta::File.new('filename.rb', {type:'generic', user:'duck', group:'workers'}), Meta::File.new('filename_spec.rb', {type:'spec', user:'donald', group:'workers'})]
    end

  end

  # it 'gets a file by one of its tag name and value' do
  #   should fail
  #   #mp.add Meta::File.new('filename_spec.rb', {type:'spec', user:'donald', group:'workers'})
  #   #mp.get('filename.rb').should == Meta::File.new("filename.rb", {:type=>"generic", :user=>"duck", :group=>"workers"})
  # end

end #Pool
end  #Meta
