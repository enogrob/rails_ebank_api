require 'rails_helper'

RSpec.describe 'Balances API', type: :request do
  before(:each) { Account.reset }

  describe 'GET /balance' do
    it 'returns balance for existing account' do
      Account.create('100', 42)
      get '/balance', params: { account_id: '100' }
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq('42')
    end

    it 'returns 404 for non-existent account' do
      get '/balance', params: { account_id: '999' }
      expect(response).to have_http_status(:not_found)
      expect(response.body).to eq('0')
    end
  end
end
