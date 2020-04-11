require 'rails_helper'

RSpec.describe 'Get cuisines', type: :request do
  let!(:user) { Fabricate(:user) }

  describe 'GET /cuisines' do
    it 'request without JWT token' do
      get '/cuisines'
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end

    it 'responds with JSON with JWT' do
      jwt = confirm_and_login_user(user)
      get '/cuisines', headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json.size).to eq(10)
      expect(json[0]['name']).to eq 'american'
    end
  end
end
