class Meal < ApplicationRecord
  extend Enumerize
  validates :name, :presence => true, :length => {:minimum => 3, :maximum => 50}

  enumerize :status, in: [:Active, :Disabled, :OutOfStock], default: :Active
  enumerize :course, in: [:Appetizer, :Breakfast, :MainCourse, :Desserts, :Salad, :Soup], default: :MainCourse
  enumerize :spice_level, in: [:Low, :Medium, :High], default: :Medium

  validates :description, :length => {:maximum => 200}
  validates :ingredients, :length => {:maximum => 200}
  validates :price, numericality: {greater_than_or_equal_to: 0.1, less_than_or_equal_to: 5000}, :presence => true
  validates :serves, numericality: {greater_than_or_equal_to: 1, less_than_or_equal_to: 50}, :allow_blank => true

  belongs_to :restaurant
  belongs_to :cuisine
  validate :ensure_correct_values
  has_many :order_items

  validates_uniqueness_of :name, scope: %i[restaurant_id]

  def ensure_correct_values(force_create = false)
    if (self.is_veg || self.is_vegan) && (self.contains_egg || self.contains_meat)
      errors.add(:values, 'are invalid')
    end
  end

end
