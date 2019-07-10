class Racer

    attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

    def self.mongo_client 
		Mongoid::Clients.default
    end

    def self.collection
        self.mongo_client['racers']
    end

    def self.all(prototype={}, sort={}, skip=0, limit=nil)

        res = self.collection.find(prototype).sort(sort).skip(skip)
        if limit == nil
            return res
        else
            return res.limit(limit)
        end
    end

    def self.find(id)
        #In case the ID is a String
        id = BSON::ObjectId(id) if id.is_a?(String)
        result = self.collection.find(_id:id).first
        return result.nil? ? nil : Racer.new(result)

    end

    def initialize(params={})
        @id=params[:_id].nil? ? params[:id] : params[:_id].to_s 
        @number=params[:number].to_i 
        @first_name=params[:first_name] 
        @last_name=params[:last_name]
        @gender=params[:gender]
        @group=params[:group]
        @secs=params[:secs].to_i
    end

    def save

        result = self.class.collection.insert_one(_id:@id, number:@number, 
        first_name:@first_name, last_name: @last_name, gender: @gender, group: @group, secs: @secs)

        @id = result.inserted_id.to_s

    end

    def update (params)

        @number=params[:number].to_i 
        @first_name=params[:first_name] 
        @last_name=params[:last_name] 
        @gender=params[:gender]
        @group=params[:group]
        @secs=params[:secs].to_i

        id = BSON::ObjectId(@id)

        params.slice!(:number, :first_name, :last_name, :gender, :group, :secs) if !params.nil?

        self.class.collection.find(_id:id).update_one('$set' => {"number":@number, "first_name": @first_name, "last_name": @last_name, "gender": @gender,
            "group": @group, "secs": @secs}) 

    end 

    def destroy
        self.class.collection.find(number:@number).delete_one
    end





  end
  

