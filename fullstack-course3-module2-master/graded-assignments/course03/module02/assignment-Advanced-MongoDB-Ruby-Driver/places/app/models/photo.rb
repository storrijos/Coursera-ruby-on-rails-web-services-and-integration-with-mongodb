
require 'exifr'
require 'exifr/jpeg'

class Photo

  attr_accessor :id, :location, :place
  attr_writer :contents

  def self.mongo_client

    return Mongoid::Clients::default

  end

  def initialize(params=nil)

    @id = params[:_id].to_s if !params.nil? && !params[:_id].nil?
    @location = Point.new(params[:metadata][:location]) if !params.nil? && !params[:metadata].nil?
    @place = params[:metadata][:place] if !params.nil? && !params[:metadata].nil?
  end

  def persisted?

    !@id.nil?

  end

  def save

    if @place.is_a? (Place)
      @place = BSON::ObjectId.from_string(@place.id)
    end


    if !persisted?

      gps = EXIFR::JPEG.new(@contents).gps
      location = Point.new(:lng=>gps.longitude, :lat=>gps.latitude)
      @contents.rewind

      description = {}
      description[:content_type] = "image/jpeg"
      description[:metadata] = {
        :location => location.to_hash,
        :place => @place
      }
      #Store data contents in GridFS
      grid_file = Mongo::Grid::File.new(@contents.read, description)
      @location = Point.new(location.to_hash)
      id = self.class.mongo_client.database.fs.insert_one(grid_file)
      @id =id.to_s

    else

      doc = self.class.mongo_client.database.fs.find(:_id=>BSON::ObjectId.from_string(@id)).first
      doc[:metadata][:location] = @location.to_hash
      doc[:metadata][:place] = @place
      self.class.mongo_client.database.fs.find(:_id=>BSON::ObjectId.from_string(@id)).update_one(doc)

    end


  end

  def place 
    if !@place.nil?
      Place.find(@place.to_s)
    end
  end

  def place=(place)
    if place.is_a? (String)
      @place = BSON::ObjectId.from_string(place)
    else
      @place = place
    end
  end


  def self.all(offset=0, limit=0)

    mongo_client.database.fs.find.skip(offset).limit(limit).map{|doc| Photo.new(doc)}

  end

  def self.find id

    doc = mongo_client.database.fs.find(:_id=>BSON::ObjectId.from_string(id)).first
    doc.nil? ? nil : photo = Photo.new(doc)

  end

  def contents

    f = self.class.mongo_client.database.fs.find_one(:_id=>BSON::ObjectId.from_string(@id))

    if f 
      buffer = ""
      f.chunks.reduce([]) do |x, chunk|
        buffer << chunk.data.data
      end

    end

      return buffer

  end


  def destroy

    self.class.mongo_client.database.fs.find(:_id=>BSON::ObjectId.from_string(@id)).delete_one

  end


  def find_nearest_place_id(max_distance)

    Place.near(@location, max_distance).limit(1).projection({:_id=>1}).first[:_id]

  end


def self.find_photos_for_place(id)
    if id.is_a? (String)
      id_arg = BSON::ObjectId.from_string(id)
    else
      id_arg = id
    end
    mongo_client.database.fs.find('metadata.place':id_arg)
  end


end
