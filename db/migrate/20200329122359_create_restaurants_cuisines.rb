class CreateRestaurantsCuisines < ActiveRecord::Migration[6.0]
  def change
    create_table(:restaurants_cuisines, :id => false) do |t|
      t.references :restaurant
      t.references :cuisine
    end
    add_index :restaurants_cuisines, [:restaurant_id, :cuisine_id], unique: true
  end
end
