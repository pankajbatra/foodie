require 'rails_helper'

RSpec.describe Order, type: :model do
  subject { Fabricate(:order)}

  before {subject.save}

  it 'status should be valid value' do
    subject.status = 'inactive'
    expect(subject).to_not be_valid
  end

  it 'status should not be blank' do
    subject.status = nil
    expect(subject).to_not be_valid
  end

  it 'payment_mode should be valid value' do
    subject.payment_mode = 'debit'
    expect(subject).to_not be_valid
  end

  it 'payment_mode should not be blank' do
    subject.payment_mode = nil
    expect(subject).to_not be_valid
  end

  it 'payment_status should be valid value' do
    subject.payment_status = 'debit'
    expect(subject).to_not be_valid
  end

  it 'payment_status should not be blank' do
    subject.payment_status = nil
    expect(subject).to_not be_valid
  end

  it 'cancel_reason should be valid value' do
    subject.cancel_reason = 'Unknown'
    expect(subject).to_not be_valid
  end

  it 'restaurant should be present' do
    subject.restaurant = nil
    expect(subject).to_not be_valid
  end

  it 'user should be present' do
    subject.user = nil
    expect(subject).to_not be_valid
  end

  it 'bill_number should not be too short' do
    subject.bill_number = ''
    expect(subject).to_not be_valid
  end

  it 'bill_number should not be too long' do
    subject.bill_number = 'a' * 51
    expect(subject).to_not be_valid
  end

  it 'eta_after_confirm should not be too low' do
    subject.eta_after_confirm = 14
    expect(subject).to_not be_valid
  end

  it 'eta_after_confirm should not be too high' do
    subject.eta_after_confirm = 181
    expect(subject).to_not be_valid
  end

  it 'eta_after_confirm should be numeric' do
    subject.eta_after_confirm = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'eta_after_confirm should be digit' do
    subject.eta_after_confirm = 20.6
    expect(subject).to_not be_valid
  end

  it 'special_request can be blank' do
    subject.special_request = nil
    expect(subject).to_not be_valid
  end

  it 'special_request should not be too short' do
    subject.special_request = 'a' * 4
    expect(subject).to_not be_valid
  end

  it 'special_request should not be too long' do
    subject.special_request = 'a' * 201
    expect(subject).to_not be_valid
  end

  it 'remarks can be blank' do
    subject.remarks = nil
    expect(subject).to_not be_valid
  end

  it 'remarks should not be too short' do
    subject.remarks = 'a' * 4
    expect(subject).to_not be_valid
  end

  it 'remarks should not be too long' do
    subject.remarks = 'a' * 201
    expect(subject).to_not be_valid
  end

  it 'tax_amount should be numeric' do
    subject.tax_amount = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'tax_amount should not be too low' do
    subject.tax_amount = -1
    expect(subject).to_not be_valid
  end

  it 'delivery_charge should be numeric' do
    subject.delivery_charge = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'delivery_charge should not be too low' do
    subject.delivery_charge = -1
    expect(subject).to_not be_valid
  end

  it 'packing_charge should be numeric' do
    subject.packing_charge = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'packing_charge should not be too low' do
    subject.packing_charge = -1
    expect(subject).to_not be_valid
  end

  it 'total_bill_amount should be numeric' do
    subject.total_bill_amount = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'total_bill_amount should not be too low' do
    subject.total_bill_amount = 0.05
    expect(subject).to_not be_valid
  end


  it 'customer_mobile should be present' do
    subject.customer_mobile = nil
    expect(subject).to_not be_valid
  end

  it 'customer_mobile should not be too short' do
    subject.customer_mobile = 99999
    expect(subject).to_not be_valid
  end

  it 'customer_mobile should not be too long' do
    subject.customer_mobile = 99999999999999999
    expect(subject).to_not be_valid
  end

  it 'customer_mobile should be numeric' do
    subject.customer_mobile = '99999999AB99'
    expect(subject).to_not be_valid
  end


  it 'customer_address should be present' do
    subject.customer_address = nil
    expect(subject).to_not be_valid
  end

  it 'customer_address should not be too short' do
    subject.customer_address = 'a' * 9
    expect(subject).to_not be_valid
  end

  it 'customer_address should not be too long' do
    subject.customer_address = 'a' * 501
    expect(subject).to_not be_valid
  end

  it 'customer_locality should not be too short' do
    subject.customer_locality = 'a' * 4
    expect(subject).to_not be_valid
  end

  it 'customer_locality should not be too long' do
    subject.customer_locality = 'a' * 256
    expect(subject).to_not be_valid
  end

  it 'customer_name should be present' do
    subject.customer_name = nil
    expect(subject).to_not be_valid
  end

  it 'customer_name should not be too short' do
    subject.customer_name = 'a'
    expect(subject).to_not be_valid
  end

  it 'customer_name should not be too long' do
    subject.customer_name = 'a' * 51
    expect(subject).to_not be_valid
  end


  it 'customer_latitude should not be too short' do
    subject.customer_latitude = -90.1
    expect(subject).to_not be_valid
  end

  it 'customer_latitude should not be too long' do
    subject.customer_latitude = 90.1
    expect(subject).to_not be_valid
  end

  it 'customer_latitude should be numeric' do
    subject.customer_latitude = '9A'
    expect(subject).to_not be_valid
  end

  it 'customer_longitude should not be too short' do
    subject.customer_longitude = -180.1
    expect(subject).to_not be_valid
  end

  it 'customer_longitude should not be too long' do
    subject.customer_longitude = 180.1
    expect(subject).to_not be_valid
  end

  it 'customer_longitude should be numeric' do
    subject.customer_longitude = '9A'
    expect(subject).to_not be_valid
  end

end

