class Account
  @@accounts = {}

  def self.find(id)
    @@accounts[id]
  end

  def self.create(id, balance)
    @@accounts[id] = balance
  end

  def self.update(id, balance)
    @@accounts[id] = balance
  end

  def self.reset
    @@accounts = {}
  end
end


