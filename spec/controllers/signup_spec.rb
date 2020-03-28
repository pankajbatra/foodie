require 'rails_helper'

RSpec.describe 'POST /signup', type: :request do
  let(:url) { '/signup' }
  let(:params) do
    {
        user: {
            email: 'user@example.com',
            password: 'password',
            mobile: '9873241200',
            name: 'tester'
        }
    }
  end

  context 'when user is unauthenticated' do
    before { post url, params: params }

    it 'returns 201' do
      expect(response.status).to eq 201
    end
  end

  context 'when user already exists' do
    before do
      Fabricate :user, email: params[:user][:email]
      post url, params: params
    end

    it 'returns 422 status' do
      expect(response.status).to eq 422
    end
  end
end