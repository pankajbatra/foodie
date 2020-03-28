class AddOwnerToRestaurant < ActiveRecord::Migration[6.0]
  def change
    add_column :restaurants, :owner_id, :integer
  end
end
