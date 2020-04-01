class CreateOrderItems < ActiveRecord::Migration[6.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false
      t.references :meal, null: false
      t.integer 'quantity', null: false
      t.string 'meal_name', limit: 50, null: false
      t.decimal 'price_per_item', precision: 10, scale: 2, null: false
      t.decimal 'sub_order_amount', precision: 10, scale: 2, null: false

      t.timestamps
    end
    add_index :order_items, [:order_id, :meal_id], unique: true
  end
end
