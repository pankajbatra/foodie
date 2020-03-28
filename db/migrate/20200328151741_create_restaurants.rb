class CreateRestaurants < ActiveRecord::Migration[6.0]
  def change
    create_table :restaurants do |t|
      t.string 'name', limit: 100, null: false
      t.string 'status', limit: 10, default: 'Active', null: false
      t.string 'description', limit: 100
      t.boolean 'open_for_delivery_now', default: true
      t.integer 'min_delivery_amount', default: 0
      t.integer 'avg_delivery_time', default: 45
      t.integer 'delivery_charge', default: 0
      t.integer 'packing_charge', default: 0
      t.decimal 'tax_percent', precision: 4, scale: 2, default: 0
      t.decimal 'rating', precision: 5, scale: 4
      t.string 'rid', limit: 10
      t.string 'phone_number', limit: 15
      t.string 'locality', limit: 100
      t.string 'address', limit: 200
      t.decimal 'latitude', precision: 17, scale: 15
      t.decimal 'longitude', precision: 18, scale: 15

      t.timestamps
    end
    add_index :restaurants, :rid, unique: true
    add_index :restaurants, [:name, :locality], unique: true
  end
end
