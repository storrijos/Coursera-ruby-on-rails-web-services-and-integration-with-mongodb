class LegResult
  include Mongoid::Document


  field :secs, type: Float
  field :event, type: Event

  validates_presence_of :event
  embedded_in :entrant
  embeds_one :event, as: :parent


  def calc_ave

  end

  after_initialize do |doc|

    doc.calc_ave

  end

  def secs= value

    self[:secs] = value
    calc_ave

  end





end
