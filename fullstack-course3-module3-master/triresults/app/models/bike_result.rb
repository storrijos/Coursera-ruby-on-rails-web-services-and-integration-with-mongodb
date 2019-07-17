class BikeResult < LegResult
  include Mongoid::Document

  field :mph, type: Float

  def calc_ave

  	if event && secs
      self.mph = event.meters.nil? ? nil : (event.miles * 3600)/secs
    end

  end
  

end
