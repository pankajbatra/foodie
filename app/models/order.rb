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
  validates :tax_amount, numericality: {greater_than_or_equal_to: 0}, :allow_blank => true
  validates :delivery_charge, numericality: {greater_than_or_equal_to: 0}, :allow_blank => false
  validates :packing_charge, numericality: {greater_than_or_equal_to: 0}, :allow_blank => false
  validates :total_bill_amount, numericality: {greater_than_or_equal_to: 0.1}, :allow_blank => true

  validates :customer_mobile,:presence => true, :numericality => true, :length => { :minimum => 10, :maximum => 15 }
  validates :customer_address, :length => {:minimum => 10, :maximum => 500}, :presence => true
  validates :customer_locality, :length => {:minimum => 5, :maximum => 255}, :allow_blank => true
  validates :customer_name, :length => {:minimum => 3, :maximum => 50}, :presence => true

  validates :customer_latitude, numericality: {greater_than_or_equal_to: -90, less_than_or_equal_to: 90}, :allow_blank => true
  validates :customer_longitude, numericality: {greater_than_or_equal_to: -180, less_than_or_equal_to: 180}, :allow_blank => true

  before_create :compute_order_amounts

  validate :validate_create, :on => :create
  validate :validate_update, :on => :update

  def validate_update
    case status

      # status can't be null
      when nil
        errors.add(:status, 'is not provided')

      # new status can't be placed
      when Order.status.values[0]
        errors.add(:status, 'is not valid: Placed')

      # Processing or Confirmed
      when Order.status.values[1]
        # previous status is not placed
        if status_was != Order.status.values[0]
          errors.add(:status, 'is not valid, can\'t mark processing now')
        elsif confirmed_at == nil
          errors.add(:confirmed_at, 'is not provided')
        end

      # In Route or Dispatched
      when Order.status.values[2]
        # previous status is not processing
        if status_was != Order.status.values[1]
          errors.add(:status, 'is not valid, can\'t mark InRoute now')
        elsif dispatched_at == nil
          errors.add(:dispatched_at, 'is not provided')
        end

      # Delivered
      when Order.status.values[3]
        # previous status is not inRoute
        if status_was != Order.status.values[2]
          errors.add(:status, 'is not valid, can\'t mark delivered now')
        elsif delivered_at == nil
          errors.add(:delivered_at, 'is not provided')
        end

      # new status received
      when Order.status.values[4]
        # previous status is not delivered yet
        if status_was != Order.status.values[3]
          errors.add(:status, 'is not valid, can\'t mark received yet')
        elsif received_at == nil
          errors.add(:received_at, 'is not provided')
        end

      # new status = Cancelled
      when Order.status.values[5]
        if status_was == Order.status.values[5] || status_was == Order.status.values[4] || status_was == Order.status.values[3]
          errors.add(:status, 'is not valid, can\'t cancel order now')
        else
          # No cancellation reason provided
          if cancel_reason == nil
            errors.add(:cancel_reason, 'is not provided')

          elsif cancelled_at == nil
            errors.add(:cancelled_at, 'is not provided')

            # order is in placed or processing, so can't send cancel reason as damaged in transit or undelivered
          elsif (status_was == Order.status.values[0] || status_was == Order.status.values[1]) &&
              (cancel_reason == Order.cancel_reason.values[7] || cancel_reason == Order.cancel_reason.values[8])
            errors.add(:cancel_reason, 'is not valid')

            # order is not in placed, so can't send cancel reason as store closed
          elsif status_was != Order.status.values[0] && cancel_reason == Order.cancel_reason.values[2]
            errors.add(:cancel_reason, 'is not valid: Store Closed')

            # customerCancel reason provided at a wrong time
          elsif cancel_reason == Order.cancel_reason.values[0] && status_was != Order.status.values[0]
            errors.add(:cancel_reason, 'is not valid: Customer Cancellation')

            # order is in route, so can't send cancel reason as out of stock, store closed or delivery person not available
          elsif status_was == Order.status.values[2] &&
              (cancel_reason == Order.cancel_reason.values[1] ||
                  cancel_reason == Order.cancel_reason.values[2] ||
                  cancel_reason == Order.cancel_reason.values[3])
            errors.add(:cancel_reason, 'is not valid at this stage')
          end
        end
      else
        # no action required
    end
  end

  def validate_create(force_create = false)
    if status == nil
      errors.add(:status, 'is not provided')
    elsif status != Order.status.values[0]
      errors.add(:status, 'is invalid')
    end

    if placed_at == nil
      errors.add(:placed_at, 'is not provided')
    end

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
    # else
      #no items sent in order
      # errors.add(:order_items, 'not provided')
    end
  end

  before_create :create_unique_identifier
  def create_unique_identifier
    begin
      self.oid = SecureRandom.hex(7)
    end while self.class.exists?(:oid => oid)
  end

  def compute_order_amounts (persist = false)
    total_order_amount = 0
    total_tax = 0
    if order_items&.length>0
      order_items.each do |order_item|
        meals_amount = order_item.meal.price * order_item.quantity
        total_order_amount+=meals_amount
      end
      total_tax = (total_order_amount*restaurant.tax_percent)/100
    end
    total_order_amount+= total_tax + restaurant.delivery_charge + restaurant.packing_charge
    self.tax_amount = total_tax
    self.total_bill_amount = total_order_amount
    if persist
      update_columns(tax_amount: total_tax, total_bill_amount: total_order_amount)
    end
  end
end

