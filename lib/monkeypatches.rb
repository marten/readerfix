class Hash
  def hash_from(*keys)
    select {|key, value| keys.map(&:to_s).include? key.to_s }
  end
end
