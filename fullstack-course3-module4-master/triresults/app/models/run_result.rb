class RunResult < LegResult
  include Mongoid::Document

  field :mmile, as: :minute_mile, type: Float

  def calc_ave
    if event && secs

      self.mmile = event.meters.nil? ? nil : (secs/60)/event.miles

    end
  end
  


  
end
