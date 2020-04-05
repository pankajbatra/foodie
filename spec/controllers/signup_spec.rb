require 'rails_helper'

RSpec.describe 'Customer Signup', type: :request do
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

  context 'when user is created' do
    before { post url, params: params }

    it 'returns 201' do
      expect(response.status).to eq 201
    end

    it 'returns customer role' do
      expect(json['roles'][0]['name']).to eq 'customer'
      expect(json['roles'].length).to eq 1
    end

    it 'returns correct data' do
      expect(json['name']).to eq params[:user][:name]
      expect(json['mobile']).to eq params[:user][:mobile]
      expect(json['email']).to eq params[:user][:email]
    end

    it 'does not contains restaurant object' do
      expect(json.has_key? 'restaurant').to eq false
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

RSpec.describe 'Restaurant Signup', type: :request do
  let(:url) { '/signup' }
  let(:params) do
    {
        user: {
            email: 'user@example.com',
            password: 'password',
            mobile: '9873241201',
            name: 'tester',
            role_names: ['restaurant']
        }
    }
  end

  context 'when user is created' do
    before { post url, params: params }

    it 'returns 201' do
      expect(response.status).to eq 201
    end

    it 'returns restaurant role' do
      expect(json['roles'][0]['name']).to eq 'restaurant'
      expect(json['roles'].length).to eq 1
    end

    it 'contains restaurant object' do
      expect(json.has_key? 'restaurant').to eq true
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