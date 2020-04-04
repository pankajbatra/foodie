class Order < ApplicationRecord
  extend Enumerize

  enumerize :status, in: [:Placed, :Processing, :InRoute, :Delivered, :Received, :Cancelled], default: :Placed
  enumerize :payment_mode, in: [:Cash, :Card, :Wallet], default: :Cash
  enumerize :payment_status, in: [:Pending, :Paid, :Settled], default: :Pending
  enumerize :cancel_reason, in: [:CustomerCancel, :OutOfStock, :StoreClosed, :DeliveryPerson, :InvalidAddress,
                                 :OutOfDeliveryArea, :PaymentFailed, :DamagedInTransit, :UnDelivered]

  belongs_to :restaurant
  belongs_to :user
  has_many :order_items, :dependent => :destroy
  accepts_nested_attributes_for :order_items

  validates :bill_number, :length => {:minimum => 1, :maximum => 50}, :allow_blank => true
  validates :eta_after_confirm, numericality: {greater_than_or_equal_to: 15, less_than_or_equal_to: 180}, :allow_blank => true
  validates :special_request, :length => {:minimum => 5, :maximum => 200}, :allow_blank => true
  validates :remarks, :length => {:minimum => 5, :maximum => 200}, :allow_blank => true
  validates :tax_amount, numericality: {greater_than_or_equal_to: 0}, :allow_blank => false
  validates :delivery_charge, numericality: {greater_than_or_equal_to: 0}, :allow_blank => false
  validates :packing_charge, numericality: {greater_than_or_equal_to: 0}, :allow_blank => false
  validates :total_bill_amount, numericality: {greater_than_or_equal_to: 0.1}, :allow_blank => false

  validates :customer_mobile,:presence => true, :numericality => true, :length => { :minimum => 10, :maximum => 15 }
  validates :customer_address, :length => {:minimum => 10, :maximum => 500}, :presence => true
  validates :customer_locality, :length => {:minimum => 5, :maximum => 255}, :allow_blank => true
  validates :customer_name, :length => {:minimum => 3, :maximum => 50}, :presence => true

  validates :customer_latitude, numericality: {greater_than_or_equal_to: -90, less_than_or_equal_to: 90}, :allow_blank => true
  validates :customer_longitude, numericality: {greater_than_or_equal_to: -180, less_than_or_equal_to: 180}, :allow_blank => true

  validate :ensure_correct_values, :on => :create

  # check status movement flow
  # check cancel reason based upon who did it

  def ensure_correct_values(force_create = false)
    # validate restaurant's status active,
    unless restaurant.status == Restaurant.status.values[0]
      errors.add(:restaurant, 'is disabled')
    end

    # validates restaurant is open
    unless restaurant.open_for_delivery_now
      errors.add(:restaurant, 'is closed for orders')
    end

    # validates user has role and is active
    unless user.is_customer? && user.status == User.status.values[0] && !user.is_blacklisted(restaurant.id)
      errors.add(:user, 'is disabled')
    end

    total_order_amount = 0
    if order_items&.length>0
      order_items.each do |order_item|
        # Items not outOfStock
        unless order_item.meal.status == Meal.status.values[0]
          errors.add(:order_items, 'is out of stock')
        end
        # invalid meal name sent
        unless order_item.meal_name == order_item.meal.name
          errors.add(:order_items, 'is invalid')
        end
        # invalid meal price sent
        unless order_item.price_per_item == order_item.meal.price
          errors.add(:order_items, 'is invalid')
        end
        meals_amount = order_item.meal.price * order_item.quantity
        # invalid sub order amount sent
        unless order_item.sub_order_amount == meals_amount
          errors.add(:order_items, 'is invalid')
        end
        total_order_amount+=meals_amount
      end

      #validate tax amount
      total_tax = (total_order_amount*restaurant.tax_percent)/100
      unless tax_amount == total_tax
          errors.add(:tax_amount, 'is invalid')
      end
      total_order_amount+=total_tax

      #validate delivery charge
      unless delivery_charge == restaurant.delivery_charge
        errors.add(:delivery_charge, 'is invalid')
      end
      total_order_amount+=restaurant.delivery_charge

      #validate packing charge
      unless packing_charge == restaurant.packing_charge
        errors.add(:packing_charge, 'is invalid')
      end
      total_order_amount+=restaurant.packing_charge

      # total amount check
      unless total_order_amount == total_bill_amount
        errors.add(:total_bill_amount, 'is invalid')
      end
    else
      #no items sent in order
      errors.add(:order_items, 'not provided')
    end
  end

  before_create :create_unique_identifier
  def create_unique_identifier
    begin
      self.oid = SecureRandom.hex(7)
    end while self.class.exists?(:oid => oid)
  end
end

