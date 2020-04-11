class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :meal
  validates :quantity,
            numericality: {
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 100,
              only_integer: true
            },
            :presence => true
  validates :meal_name, :presence => true, :length => { :minimum => 3, :maximum => 50 }
  validates :price_per_item,
            numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 5000 },
            :presence => true
  validates :sub_order_amount, numericality: { greater_than_or_equal_to: 0.1 }, :allow_blank => true

  before_create :save_sub_order_amount
  after_create :recompute_order

  validates_uniqueness_of :meal_id, scope: %i[order_id]

  private

  def save_sub_order_amount
    if self.sub_order_amount == nil || self.sub_order_amount == 0
      self.sub_order_amount = meal.price * quantity
    end
  end

  def recompute_order
    order.reload
    order.compute_order_amounts(true)
  end
end
