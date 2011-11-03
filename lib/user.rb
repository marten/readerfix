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

  def last_update
    shared_items.key["last_update"].get
  end
  

  def share!(params)
    share = Share.create(params)
    shared_items << share
    shared_items.key["last_update"].set(share.updated_at)
    share
  end

end
