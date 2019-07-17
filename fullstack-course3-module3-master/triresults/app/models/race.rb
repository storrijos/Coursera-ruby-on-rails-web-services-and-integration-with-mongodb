class Race
  include Mongoid::Document
  include Mongoid::Timestamps

  field :n, as: :name, type: String
  field :date, as: :date, type: Date
  field :loc, as: :location, type: Address

  embeds_many :events, as: :parent, order: [:order.asc]

  has_many :entrants, foreign_key: "race._id", dependent: :delete_all, order: [:secs.asc, :bib.asc]

  scope :past, ->{where(:date.lt=>Date.current)}
  scope :upcoming, ->{where(:date.gte=>Date.current)}


end
