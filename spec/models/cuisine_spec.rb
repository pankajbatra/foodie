require 'rails_helper'

RSpec.describe Cuisine, type: :model do

  subject {Cuisine.new(name: 'Americano')}

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
    subject.name = 'a' * 30
    expect(subject).to_not be_valid
  end

  it 'name should be unique' do
    subject.name = 'AMERICAN'
    expect(subject).to_not be_valid
  end

  it 'status should be valid value' do
    subject.status = 'inactive'
    expect(subject).to_not be_valid
  end

  it 'description should not be too long' do
    subject.description = 'a' * 110
    expect(subject).to_not be_valid
  end
end
