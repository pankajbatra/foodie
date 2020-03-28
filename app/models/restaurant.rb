class Restaurant < ApplicationRecord
  extend Enumerize
  rolify
  before_create :create_unique_identifier
  enumerize :status, in: [:Active, :Disabled], default: :Active

  def create_unique_identifier
    begin
      self.rid = SecureRandom.hex(10) # or whatever you chose like UUID tools
    end while self.class.exists?(:rid => rid)
  end
end
