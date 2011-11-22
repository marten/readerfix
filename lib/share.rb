require 'ohm/contrib'

class Share < Ohm::Model
  include Ohm::Timestamping

  attribute :url
  attribute :source
  attribute :title
  attribute :shorturl

  attribute :note
end
