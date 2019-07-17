class Address

  attr_accessor :city, :state, :location

  def initialize (args)

    unless args.nil?
        @city = args[:city]
        @state = args[:state]
        @location = Point.demongoize(args[:loc]) 
    end

  end

  def mongoize

    return {:city => @city, :state => @state, :loc => @location.mongoize}

  end

  def self.mongoize object

    case object
      when nil then nil 
      when Hash then Address.new(object).mongoize
      when (Address) then object.mongoize
      else object
    end

  end

  def self.demongoize object

    case object
      when nil then nil
      when Hash then Address.new(object)
      else object
    end
  end

  def self.evolve object
      self.mongoize object
  end

end
