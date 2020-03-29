class Restaurant < ApplicationRecord
  extend Enumerize
  resourcify
  before_create :create_unique_identifier
  enumerize :status, in: [:Active, :Disabled], default: :Active
  belongs_to :owner, :class_name => 'User'
  # validate :ensure_correct_owner
  validates_presence_of :owner_id
  has_and_belongs_to_many :cuisines, :join_table => :restaurants_cuisines
  has_many :meals, :dependent => :destroy

  validates :name, :presence => true, :length => {:minimum => 3, :maximum => 100}
  validates :description, :presence => true, :length => {:minimum => 10, :maximum => 100}
  validates :min_delivery_amount, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 1000,
                                                 only_integer: true}, :allow_blank => true

  validates :avg_delivery_time, numericality: {greater_than_or_equal_to: 15, less_than_or_equal_to: 180,
                                                 only_integer: true}, :allow_blank => true

  validates :delivery_charge, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 100,
                                                 only_integer: true}, :allow_blank => true

  validates :packing_charge, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 100,
                                             only_integer: true}, :allow_blank => true

  validates :tax_percent, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 30},
            :allow_blank => true

  validates :rating, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 5},
            :allow_blank => true

  validates :phone_number,  :allow_blank => true,
            :numericality => true,
            :length => { :minimum => 10, :maximum => 15 }

  validates :locality, :presence => true, :length => {:minimum => 3, :maximum => 100}
  validates :address, :length => {:minimum => 3, :maximum => 200},  :allow_blank => true

  validates :latitude, numericality: {greater_than_or_equal_to: -90, less_than_or_equal_to: 90},
            :allow_blank => true

  validates :longitude, numericality: {greater_than_or_equal_to: -180, less_than_or_equal_to: 180},
            :allow_blank => true

  def create_unique_identifier
    begin
      self.rid = SecureRandom.hex(5) # or whatever you chose like UUID tools
    end while self.class.exists?(:rid => rid)
  end

  # def ensure_correct_owner(force_create = false)
  #   user = User.find(self.owner_id)
  #   if !user.is_restaurant_owner? || (user.restaurant!=nil && user.restaurant.rid!=self.rid)
  #     errors.add(:owner, 'is invalid')
  #   end
  # end

  def cuisine_ids=(cuisine_ids)
    if self.cuisines&.length>0
      self.cuisines.each do |cuisine|
        if cuisine_ids.include?(cuisine.id)
          # already exists, no need to add again
          cuisine_ids.delete(cuisine.id)
        else
          # not there on new list, association needs to be removed from db
          self.cuisines.delete(cuisine)
        end
      end
    end
    cuisines = Cuisine.where('id IN (?)', cuisine_ids)
    self.cuisines << cuisines
  end
end
