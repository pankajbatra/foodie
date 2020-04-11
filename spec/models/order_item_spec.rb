require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  let!(:order) { Fabricate(:order, create_items: false) }
  subject {
    Fabricate(
      :order_item,
      meal: order.restaurant.meals[0],
      order: order,
      quantity: 2,
      meal_name: order.restaurant.meals[0].name,
      price_per_item: order.restaurant.meals[0].price
    )
  }

  before { subject.save }

  it 'order should be present' do
    subject.order = nil
    expect(subject).to_not be_valid
  end

  it 'meal should be present' do
    subject.meal = nil
    expect(subject).to_not be_valid
  end

  context '.' do
    before {
      Fabricate(
        :order_item,
        meal: order.restaurant.meals[1],
        order: order,
        quantity: 1,
        meal_name: order.restaurant.meals[1].name,
        price_per_item: order.restaurant.meals[1].price
      )
    }
    it 'meal should be unique for order' do
      subject.meal_id = order.restaurant.meals[1].id
      expect(subject).to be_invalid
    end
  end

  it 'quantity should be present' do
    subject.quantity = nil
    expect(subject).to_not be_valid
  end

  it 'quantity should be numeric' do
    subject.quantity = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'quantity should be digit' do
    subject.quantity = 3.6
    expect(subject).to_not be_valid
  end

  it 'quantity should not be too high' do
    subject.quantity = 101
    expect(subject).to_not be_valid
  end

  it 'quantity should not be too low' do
    subject.quantity = 0
    expect(subject).to_not be_valid
  end

  it 'meal_name should be present' do
    subject.meal_name = nil
    expect(subject).to_not be_valid
  end

  it 'meal_name should not be too short' do
    subject.meal_name = 'a'
    expect(subject).to_not be_valid
  end

  it 'meal_name should not be too long' do
    subject.meal_name = 'a' * 51
    expect(subject).to_not be_valid
  end

  it 'price_per_item should be present' do
    subject.price_per_item = nil
    expect(subject).to_not be_valid
  end

  it 'price_per_item should be numeric' do
    subject.price_per_item = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'price_per_item should not be too high' do
    subject.price_per_item = 5001
    expect(subject).to_not be_valid
  end

  it 'price_per_item should not be too low' do
    subject.price_per_item = 0.01
    expect(subject).to_not be_valid
  end

  it 'sub_order_amount can be blank' do
    subject.sub_order_amount = nil
    expect(subject).to be_valid
  end

  it 'sub_order_amount should be numeric' do
    subject.sub_order_amount = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'sub_order_amount should not be too low' do
    subject.sub_order_amount = 0.01
    expect(subject).to_not be_valid
  end
end
