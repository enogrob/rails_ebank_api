require 'rails_helper'

RSpec.describe 'Reset API', type: :request do
  before(:each) { Account.create('100', 10) }

  describe 'POST /reset' do
    it 'resets all accounts and returns 200' do
      post '/reset'
      expect(response).to have_http_status(:ok)
      expect(Account.find('100')).to be_nil
    end
  end
end
