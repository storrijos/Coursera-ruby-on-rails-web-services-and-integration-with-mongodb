class Point

  attr_accessor :longitude, :latitude

  def initialize hash
    if hash[:type]
      @longitude = hash[:coordinates][0]
      @latitude = hash[:coordinates][1]
    else
      @longitude = hash[:lng]
      @latitude = hash[:lat]
    end
  end


  def to_hash

    hash = Hash.new
    hash[:type] = "Point"
    hash[:coordinates] = Array.new
    hash[:coordinates][0] = @longitude
    hash[:coordinates][1] = @latitude

    return hash
  end

end
