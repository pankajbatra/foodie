class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string 'oid', limit: 15, null: false
      t.references :restaurant, null: false
      t.references :user, null: false
      t.datetime 'placed_at'
      t.datetime 'confirmed_at'
      t.datetime 'dispatched_at'
      t.datetime 'delivered_at'
      t.datetime 'received_at'
      t.datetime 'cancelled_at'
      t.string 'bill_number', limit: 50
      t.decimal 'tax_amount', precision: 10, scale: 2, null: false
      t.integer 'delivery_charge', null: false
      t.integer 'packing_charge', null: false
      t.decimal 'total_bill_amount', precision: 10, scale: 2, null: false
      t.string 'status', limit: 20, default: 'Placed', null: false
      t.string 'payment_mode', limit: 50, null: false
      t.string 'payment_status', limit: 20, default: 'Pending', null: false
      t.string 'special_request', limit: 200
      t.integer 'eta_after_confirm'
      t.string 'cancel_reason', limit: 50
      t.string 'customer_mobile', limit: 15, null: false
      t.string 'customer_address', limit: 500, null: false
      t.string 'customer_locality', limit: 255
      t.decimal 'customer_latitude', precision: 17, scale: 15
      t.decimal 'customer_longitude', precision: 18, scale: 15
      t.string 'customer_name', limit: 50, null: false
      t.string 'remarks', limit: 200

      t.timestamps
    end
    add_index :orders, :oid, :unique => true
  end
end
