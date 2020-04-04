class CreateRestaurantBlacklistings < ActiveRecord::Migration[6.0]
  def change
    create_table(:restaurant_blacklistings) do |t|
      t.references :restaurant, null: false
      t.references :user, null: false

      t.timestamps
    end
    add_index :restaurant_blacklistings, [:restaurant_id, :user_id], unique: true
  end
end
