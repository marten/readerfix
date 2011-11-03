require 'share'

class User < Ohm::Model
  attribute :username
  index :username
  attribute :token
  list :shared_items, Share

  def self.by_username(username)
    find(username: username).all[0]
  end

  def validate
    assert_unique :username
  end

  def validate_token(t)
    token == t
  end

  def share!(params)
    shared_items << Share.create(params)
  end

end
