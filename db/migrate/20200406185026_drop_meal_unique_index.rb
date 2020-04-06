class DropMealUniqueIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :meals, name: 'index_meals_on_restaurant_id_and_name'
  end
end
