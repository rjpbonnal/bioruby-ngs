module Meta

  class Data
    attr_accessor :metadata

    def initialize(name, metadata={})
      @metadata = {}
      @metadata[:name] = name
      @metadata.merge! metadata
    end

    def name
      @metadata[:name]
    end

    def name=(val)
      @metadata[:name]=val
    end

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


    def to_json(*a)
      {
        "json_class"   => self.class.name,
        "name"         => name,
        "metadata"    => metadata
      }.to_json(*a)
    end

    def self.json_create(o)
      me = new(o["name"], o["metadata"])
    end
    # end #Data

    # class File
    #   include Data


    #TODO: make this class generic and available to other classes
    #TODO: include or subclass original class File, I need to borrow most of its methods. File.exists? File.open File.read

    #TODO: configure a generic classifier to add any kind of tag passing a block do/yield?
  end #File

  #TODO: this class could be generalized
  class Pool < Data
    include Enumerable
    # include Data
    attr_accessor :pool
    def initialize(name=SecureRandom.uuid)
      super(name)
      @pool = {}
    end

    def to_json(*a)
      {
        "json_class"   => self.class.name,
        "name"         => name,
        "pool"     => pool
      }.to_json(*a)
    end

    def self.json_create(o)
      me = new(o["name"])
      me.pool=o["pool"]
      me
    end

    def each &block
      pool.each_pair{|name, member| block.call(name, member)}
    end

    # TODO implement <=>


    def add(element)
      unless element.nil?
        if @pool.key? element.name #TODO I don't know if this is correct.
          @pool[element.name].metadata.merge! element.metadata
        else
          @pool[element.name]=element
        end
      end
    end
    alias :<< :add

    def empty?
      @pool.empty?
    end

    def names
      @pool.keys
    end

    def get(name_or_tag_or_value, value=nil)
      # TODO implement recursive query or passing multiple values as hash, insercet or etc.....
      #       if name_or_tag_or_value.is_a? Hash
      #         name_or_tag_or_value.each_pair  do |tag, value|
      #
      #         end
      #       else
      if value
        get_by_tag_and_value(name_or_tag_or_value, value)
      else
        get_by_name(name_or_tag_or_value) || get_by_tag(name_or_tag_or_value) || get_by_value(name_or_tag_or_value) || get_down_to_childer(name_or_tag_or_value)
      end
      # end
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
      ret_pool = Pool.new
      @pool.each_pair do |name, meta|
        if meta.has_tag?(tag) && meta[tag]==val
          ret_pool.add meta
        else
          @pool.each_pair do |name, element|
            ret_pool.add element.get_by_tag_and_value(tag, val) if element.respond_to?(:get_by_tag_and_value) && element.respond_to?(:pool)
          end
        end
      end
      ret_pool unless ret_pool.empty?
    end #get_by_tag_and_value

    def get_down_to_childer(x)
      ret_pool = Pool.new
      @pool.each_pair do |name, element|
        ret_pool.add element.get(x) if element.respond_to?(:get) && element.respond_to?(:pool)
      end
      ret_pool unless ret_pool.empty?
    end




    private
    def get_generic(type, data)
      ret_pool = Pool.new
      type = type.to_sym
      if [:tag,:value].include? type
        @pool.each_pair do |name, meta|
          if meta.send("has_#{type}?", data)
            ret_pool.add(meta)
          end
        end
        ret_pool unless ret_pool.empty?
      else
        raise ArgumentError, "#{type} is not a valid parameter, use only tag or value"
      end # valid parameters
    end #get_generic

  end #Pool
end #Meta
