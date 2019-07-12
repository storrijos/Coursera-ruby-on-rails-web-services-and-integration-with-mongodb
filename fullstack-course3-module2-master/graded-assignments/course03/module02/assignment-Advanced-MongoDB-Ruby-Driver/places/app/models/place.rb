class Place
  include Mongoid::Document

  attr_accessor :id, :formatted_address, :location, :address_components

  def initialize hash

    @id = hash[:_id].to_s

    @address_components = Array.new
    
    if !hash[:address_components].nil?
        address_components = hash[:address_components]
      #We introduce each element inside the component collection
      address_components.each do |component|
        @address_components << AddressComponent.new(component)
      end
    end
    @formatted_address = hash[:formatted_address]
    @location = Point.new(hash[:geometry][:geolocation])

  end


  def self.mongo_client
    Mongoid::Clients.default
  end

  def self.collection
    return mongo_client['place']
  end

  def self.load_all file_path
    file = File.read(file_path)
    h = JSON.parse(file)
    self.collection.insert_many(h)
  end


  def self.find_by_short_name name 

    self.collection.find({"address_components.short_name": name})

  end

  def self.to_places places

    places_ret = Array.new

    places.each do |place|

      places_ret << Place.new(place)

    end

    return places_ret

  end

  def self.find id 

    doc = self.collection.find(:_id => BSON::ObjectId.from_string(id)).first

    unless doc.nil?
      place = Place.new(doc)
    end

    return place

  end

  def self.all (offset=0, limit=nil)

    docs = self.collection.find.skip(offset)

    unless limit.nil?
      docs = docs.limit(limit)
    end

    docs.map do |doc|

      Place.new(doc)
    
    end

  end

  def destroy 

    Place.collection.find(:_id => BSON::ObjectId.from_string(@id)).delete_one

  end

  def self.get_address_components (sort=nil, offset=0, limit=nil)

    if sort.nil? && limit.nil?
      self.collection.find.aggregate([
        {:$unwind=>'$address_components'},
        {:$project => {:_id => 1, :address_components => 1, :formatted_address=>1, :geometry => {:geolocation => 1}}}, 
        {:$skip => offset}])
    elsif sort.nil? && !limit.nil?
      self.collection.find.aggregate([
        {:$unwind=>'$address_components'},
        {:$project => {:_id => 1, :address_components => 1, :formatted_address=>1, :geometry => {:geolocation => 1}}}, 
        {:$skip => offset}, 
        {:$limit => limit}])
    elsif !sort.nil? && limit.nil?
      self.collection.find.aggregate([
        {:$unwind=>'$address_components'},
        {:$project => {:_id => 1, :address_components => 1, :formatted_address=>1, :geometry => {:geolocation => 1}}}, 
        {:$sort => sort}, 
        {:$skip => offset}])
    else
      self.collection.find.aggregate([
        {:$unwind=>'$address_components'}, 
        {:$project => {:_id => 1, :address_components => 1, :formatted_address=>1, :geometry => {:geolocation => 1}}}, 
        {:$sort => sort}, 
        {:$skip => offset}, 
        {:$limit => limit}])
    end

  end

def self.get_country_names

  self.collection.find.aggregate([
  {:$unwind => '$address_components'},
  {:$project => {:_id => 0, :address_components => {:long_name => 1, :types => 1}}},
  {:$match => {'address_components.types': "country"}},
  {:$group => {:_id => '$address_components.long_name', 
  :count => {:$sum=>1}}}]).to_a.map{|h| h[:_id]}

end

def self.find_ids_by_country_code country_code

  self.collection.find.aggregate([
    {:$match => {'address_components.short_name' => country_code}},
    {:$project => {:_id => 1}}]).map{|doc| doc[:_id].to_s}

end

def self.create_indexes
  self.collection.indexes.create_one({'geometry.geolocation': Mongo::Index::GEO2DSPHERE})
end

def self.remove_indexes
  self.collection.indexes.drop_one('geometry.geolocation_2dsphere')
end

def self.near (point, max_meters=nil)
  if max_meters.nil?
    self.collection.find({'geometry.geolocation': 
      {:$near => point.to_hash}})
  else
    self.collection.find({'geometry.geolocation': 
      {:$near => point.to_hash, :$maxDistance => max_meters.to_i}})
  end

end

def near (max_meters=nil)

  near_points = Array.new
  Place.near(@location, max_meters).each {|p| near_points << Place.new(p)}

  return near_points

end



end
