class Point
  attr_accessor :longitude, :latitude
  
  def initialize (longitude, latitude)
    @longitude = longitude
    @latitude = latitude
  end

  def mongoize
    {:type=>'Point', :coordinates=>[@longitude,@latitude]}
  end

  def self.demongoize(hash)

    if hash.instance_of? Hash
        p = Point.new(hash[:coordinates][0], hash[:coordinates][1])
    elsif hash.instance_of? Point
      hash
    else nil
    end

    return p

  end

  def self.mongoize (object)

    if object.instance_of? Hash
          Point.new(object[:coordinates][0], object[:coordinates][1]).mongoize
    elsif object.instance_of? Point
          object.mongoize
    else nil 
    end

  end

  def self.evolve(object) 
    self.mongoize(object)
  end

end
