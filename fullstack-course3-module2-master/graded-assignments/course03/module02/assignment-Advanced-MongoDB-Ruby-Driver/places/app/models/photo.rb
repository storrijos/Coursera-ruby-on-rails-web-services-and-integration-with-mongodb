
require 'exifr'
require 'exifr/jpeg'

class Photo

  attr_accessor :id, :location
  attr_writer :contents

  def self.mongo_client

    return Mongoid::Clients::default

  end

  def initialize(params=nil)

    @id = params[:_id].to_s if !params.nil? && !params[:_id].nil?
    @location = Point.new(params[:metadata][:location]) if !params.nil? && !params[:metadata].nil?

  end

  def persisted?

    !@id.nil?

  end

  def save

    if !persisted?

      gps = EXIFR::JPEG.new(@contents).gps
      location = Point.new(:lng=>gps.longitude, :lat=>gps.latitude)
      @contents.rewind

      description = {}
      description[:content_type] = "image/jpeg"
      description[:metadata] = {
        :location => location.to_hash
      }
      #Store data contents in GridFS
      grid_file = Mongo::Grid::File.new(@contents.read, description)
      @location = Point.new(location.to_hash)
      id = self.class.mongo_client.database.fs.insert_one(grid_file)
      @id =id.to_s

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




end
