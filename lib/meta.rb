module Meta

  module Data
    attr_accessor :metadata

    def ==(other)
      if self.name==other.name && self.metadata==other.metadata
        true
      else
        false
      end
    end

    def has_tag?(tag)
      metadata.key? tag
    end

    def has_value?(val)
      metadata.each_pair do |tag, value|
        return true if value == val
      end
      return false
    end

    def [](tag)
      metadata[tag]
    end
  end #Data

  class File
    include Data
    attr_accessor :name

    def initialize(name, metadata={})
      @name = name
      @metadata = metadata
    end

    #TODO: make this class generic and available to other classes
    #TODO: include or subclass original class File, I need to borrow most of its methods. File.exists? File.open File.read

    #TODO: configure a generic classifier to add any kind of tag passing a block do/yield?

    # write in the metadata[:tag_name] the value returned by block
    # def self.attach_tag(tag_name, &block)
    #   @metadata[tag_name.to_sym]=block.call
    # end
  end #File

  #TODO: this class could be generalized
  class Pool
    include Data
    attr_accessor :name, :pool
    def initialize(name)
      @name = name
      @pool = {}
      @metadata = {}
    end

    def add(element)
      if @pool.key? element.name
        @pool[element.name].metadata.merge! element.metadata
      else
        @pool[element.name]=element
      end
    end
    alias :<< :add

    def get(name_or_tag_or_value=nil)
      get_by_name(name_or_tag_or_value) || get_by_tag(name_or_tag_or_value) || get_by_value(name_or_tag_or_value) || get_down_to_childer(name_or_tag_or_value)
    end #get

    def get_by_name(name)
      @pool[name]
    end #get_by_name

    def get_by_tag(tag)
      get_generic :tag, tag
    end #get_by_tag

    def get_by_value(val)
      get_generic :value, val
    end #get_by_value

    def get_by_tag_and_value(tag, val)
      res = []
      @pool.each_pair do |name, meta|
        if meta.has_tag?(tag) && meta[tag]==val
          res << meta
        else
          @pool.each_pair do |name, element|
            res << element.get_by_tag_and_value(tag, val) if element.respond_to?(:get_by_tag_and_value) && element.respond_to?(:pool)
          end
        end
      end
      if res.empty?
        nil
      elsif res.size == 1
        res.first
      else
        res.flatten
      end
    end #get_by_tag_and_value

    def get_down_to_childer(x)
      res = []
      @pool.each_pair do |name, element|
        res << element.get(x) if element.respond_to?(:get) && element.respond_to?(:pool)
      end
      res.flatten
    end

    def to_json(*a)
      {
        "json_class"   => self.class.name,
        "name"         => name,
        "filenames"    => metadata
      }.to_json(*a)
    end

    private
    def get_generic(type, data)
      type = type.to_sym
      if [:tag,:value].include? type
        res = []
        @pool.each_pair do |name, meta|
          if meta.send("has_#{type}?", data)
            res << meta
          end
        end
        if res.empty?
          nil
        elsif res.size == 1
          res.first
        else
          res
        end
      else
        raise ArgumentError, "#{type} is not a valid parameter, use only tag or value"
      end # valid parameters
    end #get_generic

  end #Pool
end #Meta
