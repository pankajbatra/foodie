class Cuisine < ApplicationRecord
  extend Enumerize
  validates :name,
            :presence => true,
            :length => { :minimum => 3, :maximum => 20 },
            uniqueness: { case_sensitive: false }

  enumerize :status, in: [:Active, :Disabled], default: :Active
  validates :description, :length => { :maximum => 100 }
  has_and_belongs_to_many :restaurants, :join_table => :restaurants_cuisines
  has_many :meals
end
