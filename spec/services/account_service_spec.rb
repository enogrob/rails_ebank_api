require 'rails_helper'

RSpec.describe AccountService do
  before(:each) { Account.reset }

  describe '.deposit' do
    it 'creates a new account and deposits amount' do
      result = described_class.deposit('100', 10)
      expect(result[:body]).to eq({ destination: { id: '100', balance: 10 } })
      expect(result[:status]).to eq(:created)
      expect(Account.find('100')).to eq(10)
    end

    it 'deposits into an existing account' do
      Account.create('100', 5)
      result = described_class.deposit('100', 10)
      expect(result[:body]).to eq({ destination: { id: '100', balance: 15 } })
      expect(result[:status]).to eq(:created)
      expect(Account.find('100')).to eq(15)
    end
  end

  describe '.withdraw' do
    it 'returns not_found for non-existing account' do
      result = described_class.withdraw('200', 10)
      expect(result[:body]).to eq(0)
      expect(result[:status]).to eq(:not_found)
    end

    it 'withdraws from an existing account' do
      Account.create('100', 20)
      result = described_class.withdraw('100', 5)
      expect(result[:body]).to eq({ origin: { id: '100', balance: 15 } })
      expect(result[:status]).to eq(:created)
      expect(Account.find('100')).to eq(15)
    end
  end

  describe '.transfer' do
    it 'returns not_found if origin account does not exist' do
      result = described_class.transfer('200', 10, '300')
      expect(result[:body]).to eq(0)
      expect(result[:status]).to eq(:not_found)
    end

    it 'transfers to an existing destination account' do
      Account.create('100', 20)
      Account.create('300', 5)
      result = described_class.transfer('100', 10, '300')
      expect(result[:body]).to eq({
        origin: { id: '100', balance: 10 },
        destination: { id: '300', balance: 15 }
      })
      expect(result[:status]).to eq(:created)
      expect(Account.find('100')).to eq(10)
      expect(Account.find('300')).to eq(15)
    end

    it 'transfers to a new destination account' do
      Account.create('100', 20)
      result = described_class.transfer('100', 10, '400')
      expect(result[:body]).to eq({
        origin: { id: '100', balance: 10 },
        destination: { id: '400', balance: 10 }
      })
      expect(result[:status]).to eq(:created)
      expect(Account.find('100')).to eq(10)
      expect(Account.find('400')).to eq(10)
    end
  end

  describe '.get_balance' do
    it 'returns not_found for non-existing account' do
      result = described_class.get_balance('999')
      expect(result[:body]).to eq(0)
      expect(result[:status]).to eq(:not_found)
    end

    it 'returns balance for existing account' do
      Account.create('100', 42)
      result = described_class.get_balance('100')
      expect(result[:body]).to eq(42)
      expect(result[:status]).to eq(:ok)
    end
  end

  describe '.reset_accounts' do
    it 'resets all accounts' do
      Account.create('100', 10)
      described_class.reset_accounts
      expect(Account.find('100')).to be_nil
    end
  end

  describe '.process_event' do
    it 'handles deposit event' do
      result = described_class.process_event({ type: 'deposit', destination: '100', amount: 10 })
      expect(result[:body]).to eq({ destination: { id: '100', balance: 10 } })
      expect(result[:status]).to eq(:created)
    end

    it 'handles withdraw event' do
      Account.create('100', 20)
      result = described_class.process_event({ type: 'withdraw', origin: '100', amount: 5 })
      expect(result[:body]).to eq({ origin: { id: '100', balance: 15 } })
      expect(result[:status]).to eq(:created)
    end

    it 'handles transfer event' do
      Account.create('100', 20)
      result = described_class.process_event({ type: 'transfer', origin: '100', amount: 10, destination: '200' })
      expect(result[:body]).to eq({
        origin: { id: '100', balance: 10 },
        destination: { id: '200', balance: 10 }
      })
      expect(result[:status]).to eq(:created)
    end

    it 'returns bad_request for unknown event type' do
      result = described_class.process_event({ type: 'unknown' })
      expect(result[:body]).to eq(0)
      expect(result[:status]).to eq(:bad_request)
    end
  end
end