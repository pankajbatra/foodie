require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  subject {Fabricate(:restaurant, name: 'Spice Junction', locality: 'Broadway')}

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
    subject.name = 'a' * 101
    expect(subject).to_not be_valid
  end

  it 'description should be present' do
    subject.description = nil
    expect(subject).to_not be_valid
  end

  it 'description should not be too short' do
    subject.description = 'a' * 9
    expect(subject).to_not be_valid
  end

  it 'description should not be too long' do
    subject.description = 'a' * 101
    expect(subject).to_not be_valid
  end

  it 'min_delivery_amount should not be too low' do
    subject.min_delivery_amount = -1
    expect(subject).to_not be_valid
  end

  it 'min_delivery_amount should not be too high' do
    subject.min_delivery_amount = 1001
    expect(subject).to_not be_valid
  end

  it 'min_delivery_amount can be blank' do
    subject.min_delivery_amount = nil
    expect(subject).to be_valid
  end

  it 'min_delivery_amount should be numeric' do
    subject.min_delivery_amount = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'min_delivery_amount should be digit' do
    subject.min_delivery_amount = 20.6
    expect(subject).to_not be_valid
  end

  it 'avg_delivery_time should not be too low' do
    subject.avg_delivery_time = 14
    expect(subject).to_not be_valid
  end

  it 'avg_delivery_time should not be too high' do
    subject.avg_delivery_time = 181
    expect(subject).to_not be_valid
  end

  it 'avg_delivery_time can be blank' do
    subject.avg_delivery_time = nil
    expect(subject).to be_valid
  end

  it 'avg_delivery_time should be numeric' do
    subject.avg_delivery_time = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'avg_delivery_time should be digit' do
    subject.avg_delivery_time = 20.6
    expect(subject).to_not be_valid
  end

  it 'delivery_charge should not be too low' do
    subject.delivery_charge = -1
    expect(subject).to_not be_valid
  end

  it 'delivery_charge should not be too high' do
    subject.delivery_charge = 101
    expect(subject).to_not be_valid
  end

  it 'delivery_charge can be blank' do
    subject.delivery_charge = nil
    expect(subject).to be_valid
  end

  it 'delivery_charge should be numeric' do
    subject.delivery_charge = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'delivery_charge should be digit' do
    subject.delivery_charge = 20.6
    expect(subject).to_not be_valid
  end

  it 'packing_charge should not be too low' do
    subject.packing_charge = -1
    expect(subject).to_not be_valid
  end

  it 'packing_charge should not be too high' do
    subject.packing_charge = 101
    expect(subject).to_not be_valid
  end

  it 'packing_charge can be blank' do
    subject.packing_charge = nil
    expect(subject).to be_valid
  end

  it 'packing_charge should be numeric' do
    subject.packing_charge = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'packing_charge should be digit' do
    subject.packing_charge = 20.6
    expect(subject).to_not be_valid
  end

  it 'tax_percent should not be too low' do
    subject.tax_percent = -1
    expect(subject).to_not be_valid
  end

  it 'tax_percent should not be too high' do
    subject.tax_percent = 31
    expect(subject).to_not be_valid
  end

  it 'tax_percent can be blank' do
    subject.tax_percent = nil
    expect(subject).to be_valid
  end

  it 'tax_percent should be numeric' do
    subject.tax_percent = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'rating should not be too low' do
    subject.rating = -1
    expect(subject).to_not be_valid
  end

  it 'rating should not be too high' do
    subject.rating = 5.1
    expect(subject).to_not be_valid
  end

  it 'rating can be blank' do
    subject.rating = nil
    expect(subject).to be_valid
  end

  it 'rating should be numeric' do
    subject.rating = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'phone_number should not be too short' do
    subject.phone_number = 99999
    expect(subject).to_not be_valid
  end

  it 'phone_number should not be too long' do
    subject.phone_number = 99999999999999999
    expect(subject).to_not be_valid
  end

  it 'phone_number should be numeric' do
    subject.phone_number = '99999999AB99'
    expect(subject).to_not be_valid
  end

  it 'phone_number can be blank' do
    subject.phone_number = nil
    expect(subject).to be_valid
  end

  it 'locality should be present' do
    subject.locality = nil
    expect(subject).to_not be_valid
  end

  it 'locality should not be too short' do
    subject.locality = 'a' * 2
    expect(subject).to_not be_valid
  end

  it 'locality should not be too long' do
    subject.locality = 'a' * 101
    expect(subject).to_not be_valid
  end

  it 'address can be blank' do
    subject.address = nil
    expect(subject).to be_valid
  end

  it 'address should not be too short' do
    subject.address = 'a' * 2
    expect(subject).to_not be_valid
  end

  it 'address should not be too long' do
    subject.address = 'a' * 201
    expect(subject).to_not be_valid
  end

  it 'latitude should not be too short' do
    subject.latitude = -90.1
    expect(subject).to_not be_valid
  end

  it 'latitude should not be too long' do
    subject.latitude = 90.1
    expect(subject).to_not be_valid
  end

  it 'latitude should be numeric' do
    subject.latitude = '9A'
    expect(subject).to_not be_valid
  end

  it 'latitude can be blank' do
    subject.latitude = nil
    expect(subject).to be_valid
  end

  it 'longitude should not be too short' do
    subject.longitude = -180.1
    expect(subject).to_not be_valid
  end

  it 'longitude should not be too long' do
    subject.longitude = 180.1
    expect(subject).to_not be_valid
  end

  it 'longitude should be numeric' do
    subject.longitude = '9A'
    expect(subject).to_not be_valid
  end

  it 'longitude can be blank' do
    subject.longitude = nil
    expect(subject).to be_valid
  end

  it 'owner should be present' do
    subject.owner = nil
    expect(subject).to_not be_valid
  end

  it 'status should be valid value' do
    subject.status = 'inactive'
    expect(subject).to_not be_valid
  end

  context '.' do
    before {Fabricate(:restaurant, name: 'Spice Box', locality: 'Broadway Street')}
    it 'restaurant name should be unique for locality' do
      subject.name = 'SPICE Box'
      subject.locality = 'BroadWay Street'
      expect(subject).to be_invalid
    end
  end
end
