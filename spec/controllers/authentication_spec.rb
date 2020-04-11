require 'rails_helper'

RSpec.describe 'Customer Login', type: :request do
  let(:user) {Fabricate(:user)}
  let(:url) {'/login'}
  let(:params) do
    {
        user: {
            email: user.email,
            password: user.password
        }
    }
  end
  let(:wrong_params) do
    {
        user: {
            email: "1#{user.email}",
            password: "1#{user.password}"
        }
    }
  end

  context 'when params are correct' do
    before do
      post url, params: params
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns customer role' do
      expect(json['roles'][0]['name']).to eq 'customer'
      expect(json['roles'].length).to eq 1
    end

    it 'returns correct data' do
      expect(json['name']).to eq user.name
      expect(json['mobile']).to eq user.mobile
      expect(json['email']).to eq user.email
    end

    it 'does not contains restaurant object' do
      expect(json.has_key? 'restaurant').to eq false
    end

    it 'returns JWT token in authorization header' do
      expect(response.headers['Authorization']).to be_present
    end

    it 'returns valid JWT token' do
      token_from_request = response.headers['Authorization'].split(' ').last
      decoded_token = JWT.decode(token_from_request, Rails.application.credentials.devise_jwt_secret_key, true)
      expect(decoded_token.first['sub']).to be_present
    end
  end

  context 'when login params are incorrect' do
    before {post url}
    before do
      post url, params: wrong_params
    end

    it 'returns unauthorized status' do
      expect(response.status).to eq 401
    end
  end
end

RSpec.describe 'Customer logout', type: :request do
  let!(:user) {Fabricate(:user)}
  let(:url) {'/logout'}

  it 'returns 200, no content' do
    jwt = confirm_and_login_user(user)
    expect(json['email']).to eq user.email
    delete url
    expect(response).to have_http_status(200)
    get '/cuisines', headers: {:Authorization => "Bearer #{jwt}"}
    expect(response).to have_http_status(401)
    expect(response.body).to eq 'Not enough or too many segments'
  end
end

RSpec.describe 'Restaurant Login', type: :request do
  let(:user) {Fabricate(:restaurant_owner)}
  let(:url) {'/login'}
  let(:params) do
    {
        user: {
            email: user.email,
            password: user.password
        }
    }
  end
  let(:wrong_params) do
    {
        user: {
            email: "1#{user.email}",
            password: "1#{user.password}"
        }
    }
  end

  context 'when params are correct' do
    before do
      post url, params: params
    end

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns restaurant role' do
      expect(json['roles'][0]['name']).to eq 'restaurant'
      expect(json['roles'].length).to eq 1
    end

    it 'contains restaurant object' do
      expect(json.has_key? 'restaurant').to eq true
    end

    it 'returns JWT token in authorization header' do
      expect(response.headers['Authorization']).to be_present
    end

    it 'returns valid JWT token' do
      token_from_request = response.headers['Authorization'].split(' ').last
      decoded_token = JWT.decode(token_from_request, Rails.application.credentials.devise_jwt_secret_key, true)
      expect(decoded_token.first['sub']).to be_present
    end
  end

  context 'when login params are incorrect' do
    before {post url}
    before do
      post url, params: wrong_params
    end

    it 'returns unauthorized status' do
      expect(response.status).to eq 401
    end
  end
end

RSpec.describe 'Restaurant logout', type: :request do
  let!(:user) {Fabricate(:restaurant_owner)}
  let(:url) {'/logout'}

  it 'returns 200, no content' do
    jwt = confirm_and_login_user(user)
    expect(json['email']).to eq user.email
    delete url
    expect(response).to have_http_status(200)
    get '/cuisines', headers: {:Authorization => "Bearer #{jwt}"}
    expect(response).to have_http_status(401)
    expect(response.body).to eq 'Not enough or too many segments'
  end
end