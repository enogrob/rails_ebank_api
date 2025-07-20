require 'rails_helper'

RSpec.describe 'Events API', type: :request do
  before(:each) { Account.reset }

  describe 'POST /event' do
    it 'deposits to a new account' do
      post '/event', params: { type: 'deposit', destination: '100', amount: 10 }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to eq({ 'destination' => { 'id' => '100', 'balance' => 10 } })
    end

    it 'deposits to an existing account' do
      Account.create('100', 5)
      post '/event', params: { type: 'deposit', destination: '100', amount: 10 }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to eq({ 'destination' => { 'id' => '100', 'balance' => 15 } })
    end

    it 'withdraws from an existing account' do
      Account.create('100', 20)
      post '/event', params: { type: 'withdraw', origin: '100', amount: 5 }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to eq({ 'origin' => { 'id' => '100', 'balance' => 15 } })
    end

    it 'returns 404 when withdrawing from non-existent account' do
      post '/event', params: { type: 'withdraw', origin: '200', amount: 10 }
      expect(response).to have_http_status(:not_found)
      expect(response.body).to eq('0')
    end

    it 'transfers between accounts' do
      Account.create('100', 20)
      Account.create('300', 5)
      post '/event', params: { type: 'transfer', origin: '100', amount: 10, destination: '300' }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to eq({ 'origin' => { 'id' => '100', 'balance' => 10 }, 'destination' => { 'id' => '300', 'balance' => 15 } })
    end

    it 'transfers to a new destination account' do
      Account.create('100', 20)
      post '/event', params: { type: 'transfer', origin: '100', amount: 10, destination: '400' }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to eq({ 'origin' => { 'id' => '100', 'balance' => 10 }, 'destination' => { 'id' => '400', 'balance' => 10 } })
    end

    it 'returns 404 when transferring from non-existent origin account' do
      post '/event', params: { type: 'transfer', origin: '999', amount: 10, destination: '888' }
      expect(response).to have_http_status(:not_found)
      expect(response.body).to eq('0')
    end

    it 'returns 400 for unknown event type' do
      post '/event', params: { type: 'unknown' }
      expect(response).to have_http_status(:bad_request)
      expect(response.body).to eq('0')
    end
  end
end
