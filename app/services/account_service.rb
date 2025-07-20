class AccountService
  # Handles deposit, withdraw, and transfer events
  def self.process_event(params)
    case params[:type]
    when 'deposit'
      deposit(params[:destination], params[:amount])
    when 'withdraw'
      withdraw(params[:origin], params[:amount])
    when 'transfer'
      transfer(params[:origin], params[:amount], params[:destination])
    else
      { body: 0, status: :bad_request }
    end
  end

  # Handles deposit event
  def self.deposit(destination_id, amount)
    account = Account.find(destination_id)
    if account
      new_balance = account + amount.to_i
      Account.update(destination_id, new_balance)
    else
      Account.create(destination_id, amount.to_i)
      new_balance = amount.to_i
    end
    {
      body: { destination: { id: destination_id, balance: new_balance } },
      status: :created
    }
  end

  # Handles withdraw event
  def self.withdraw(origin_id, amount)
    account = Account.find(origin_id)
    return { body: 0, status: :not_found } unless account

    new_balance = account - amount.to_i
    Account.update(origin_id, new_balance)
    {
      body: { origin: { id: origin_id, balance: new_balance } },
      status: :created
    }
  end

  # Handles transfer event
  def self.transfer(origin_id, amount, destination_id)
    origin_account = Account.find(origin_id)
    return { body: 0, status: :not_found } unless origin_account

    destination_account = Account.find(destination_id)
    new_origin_balance = origin_account - amount.to_i
    Account.update(origin_id, new_origin_balance)

    if destination_account
      new_destination_balance = destination_account + amount.to_i
      Account.update(destination_id, new_destination_balance)
    else
      Account.create(destination_id, amount.to_i)
      new_destination_balance = amount.to_i
    end

    {
      body: {
        origin: { id: origin_id, balance: new_origin_balance },
        destination: { id: destination_id, balance: new_destination_balance }
      },
      status: :created
    }
  end

  # Handles balance query
  def self.get_balance(account_id)
    account = Account.find(account_id)
    if account
      { body: account, status: :ok }
    else
      { body: 0, status: :not_found }
    end
  end

  # Handles reset
  def self.reset_accounts
    Account.reset
  end
end