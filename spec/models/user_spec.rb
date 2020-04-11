require 'rails_helper'

RSpec.describe User, type: :model do
  subject {Fabricate(:user)}

  before {subject.save}

  it 'name should be present' do
    subject.name = nil
    expect(subject).to_not be_valid
  end

  it 'name should not be too short' do
    subject.name = 'a'
    expect(subject).to_not be_valid
  end

  it 'name should not be too long' do
    subject.name = 'a' * 31
    expect(subject).to_not be_valid
  end

  it 'name should not have special chars' do
    subject.name = 'Mrs. Disco 123'
    expect(subject).to_not be_valid
  end

  it 'email should be present' do
    subject.email = nil
    expect(subject).to_not be_valid
  end

  it 'email should be valid format' do
    subject.email = 'wrong'
    expect(subject).to_not be_valid
  end

  context '.' do
    before {Fabricate(:user, email: 'test@example.com')}
    it 'email should be unique' do
      subject.email = 'test@example.com'
      expect(subject).to be_invalid
    end
  end

  it 'status should be valid value' do
    subject.status = 'inactive'
    expect(subject).to_not be_valid
  end

  it 'mobile should be present' do
    subject.mobile = nil
    expect(subject).to_not be_valid
  end

  it 'mobile should not be too short' do
    subject.mobile = 99999
    expect(subject).to_not be_valid
  end

  it 'mobile should not be too long' do
    subject.mobile = 99999999999999999
    expect(subject).to_not be_valid
  end

  it 'mobile should be numeric' do
    subject.mobile = '99999999AB99'
    expect(subject).to_not be_valid
  end

  it 'password should not be too short' do
    subject.password = 'a' * 5
    expect(subject).to_not be_valid
  end

  it 'password should not be too long' do
    subject.password = 'a' * 129
    expect(subject).to_not be_valid
  end
end