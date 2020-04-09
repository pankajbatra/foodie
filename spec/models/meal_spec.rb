require 'rails_helper'

RSpec.describe Meal, type: :model do
  let!(:restaurant) { Fabricate(:restaurant, create_meals: false) }
  subject {Fabricate(:meal, restaurant: restaurant, cuisine: Cuisine.first)}

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
    subject.name = 'a' * 60
    expect(subject).to_not be_valid
  end

  it 'status should be valid value' do
    subject.status = 'inactive'
    expect(subject).to_not be_valid
  end

  it 'course should be valid value' do
    subject.course = 'aftermeal'
    expect(subject).to_not be_valid
  end

  it 'spice_level should be valid value' do
    subject.spice_level = 'very high'
    expect(subject).to_not be_valid
  end

  it 'description should not be too long' do
    subject.description = 'a' * 210
    expect(subject).to_not be_valid
  end

  it 'ingredients should not be too long' do
    subject.ingredients = 'a' * 210
    expect(subject).to_not be_valid
  end

  it 'price should be present' do
    subject.price = nil
    expect(subject).to_not be_valid
  end

  it 'price should be numeric' do
    subject.price = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'price should not be too high' do
    subject.price = 5001
    expect(subject).to_not be_valid
  end

  it 'price should not be too low' do
    subject.price = 0.01
    expect(subject).to_not be_valid
  end

  it 'serves should not be too low' do
    subject.serves = 0
    expect(subject).to_not be_valid
  end

  it 'serves should not be too high' do
    subject.serves = 51
    expect(subject).to_not be_valid
  end

  it 'serves can be blank' do
    subject.serves = nil
    expect(subject).to be_valid
  end

  it 'serves should be numeric' do
    subject.serves = 'ABC'
    expect(subject).to_not be_valid
  end

  it 'restaurant should be present' do
    subject.restaurant = nil
    expect(subject).to_not be_valid
  end

  it 'cuisine should be present' do
    subject.cuisine = nil
    expect(subject).to_not be_valid
  end

  it 'veg and meat cannot be present together' do
    subject.is_veg = true
    subject.contains_meat = true
    expect(subject).to_not be_valid
  end

  it 'vegan and meat cannot be present together' do
    subject.is_vegan = true
    subject.contains_meat = true
    expect(subject).to_not be_valid
  end

  it 'veg and egg cannot be present together' do
    subject.is_veg = true
    subject.contains_egg = true
    expect(subject).to_not be_valid
  end

  it 'vegan and egg cannot be present together' do
    subject.is_vegan = true
    subject.contains_egg = true
    expect(subject).to_not be_valid
  end

end
