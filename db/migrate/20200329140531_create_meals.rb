class CreateMeals < ActiveRecord::Migration[6.0]
  def change
    create_table :meals do |t|
      t.string 'name', limit: 50, null: false
      t.string 'status', limit: 10, default: 'Active', null: false
      t.references :restaurant, null: false
      t.references :cuisine
      t.string 'description', limit: 200
      t.boolean 'is_chef_special'
      t.boolean 'is_veg'
      t.boolean 'contains_egg'
      t.boolean 'contains_meat'
      t.boolean 'is_vegan'
      t.boolean 'is_halal'
      t.string 'course', limit: 20
      t.string 'ingredients', limit: 200
      t.string 'spice_level', limit: 10, default: 'Medium', null: false
      t.decimal 'price', precision: 7, scale: 2, null: false
      t.integer 'serves'

      t.timestamps
    end
    add_index :meals, [:restaurant_id, :name], unique: true
  end
end
