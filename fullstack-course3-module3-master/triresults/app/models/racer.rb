class Racer
  include Mongoid::Document


  embeds_one :info, class_name: 'RacerInfo', as: :parent, autobuild: true

	before_create do |racer|
		racer.info.id = racer.id
	end





end