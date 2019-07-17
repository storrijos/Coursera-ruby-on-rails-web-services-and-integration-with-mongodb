class Placing

  attr_accessor :name, :place

  def initialize (args)

    @name = args[:name]
    @place = args[:place]

  end

  def mongoize

    return {:name => @name, :place => @place}

  end

  def self.mongoize object

    case object
      when nil then nil 
      when Hash then Placing.new(object).mongoize
      when (Placing) then object.mongoize
      else object
    end

  end

  def self.demongoize object

    case object
      when nil then nil
      when Hash then Placing.new(object)
      else object
    end
  end

  def self.evolve object
      self.mongoize object
  end

end
