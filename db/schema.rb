# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_04_112000) do

  create_table "cuisines", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", limit: 20, null: false
    t.string "status", limit: 10, default: "Active", null: false
    t.string "description", limit: 100
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_cuisines_on_name", unique: true
  end

  create_table "jwt_blacklist", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp"
    t.index ["jti"], name: "index_jwt_blacklist_on_jti"
  end

  create_table "meals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "status", limit: 10, default: "Active", null: false
    t.bigint "restaurant_id", null: false
    t.bigint "cuisine_id"
    t.string "description", limit: 200
    t.boolean "is_chef_special"
    t.boolean "is_veg"
    t.boolean "contains_egg"
    t.boolean "contains_meat"
    t.boolean "is_vegan"
    t.boolean "is_halal"
    t.string "course", limit: 20
    t.string "ingredients", limit: 200
    t.string "spice_level", limit: 10, default: "Medium", null: false
    t.decimal "price", precision: 7, scale: 2, null: false
    t.integer "serves"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cuisine_id"], name: "index_meals_on_cuisine_id"
    t.index ["restaurant_id", "name"], name: "index_meals_on_restaurant_id_and_name", unique: true
    t.index ["restaurant_id"], name: "index_meals_on_restaurant_id"
  end

  create_table "order_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "meal_id", null: false
    t.integer "quantity", null: false
    t.string "meal_name", limit: 50, null: false
    t.decimal "price_per_item", precision: 10, scale: 2, null: false
    t.decimal "sub_order_amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["meal_id"], name: "index_order_items_on_meal_id"
    t.index ["order_id", "meal_id"], name: "index_order_items_on_order_id_and_meal_id", unique: true
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "oid", limit: 15, null: false
    t.bigint "restaurant_id", null: false
    t.bigint "user_id", null: false
    t.datetime "placed_at"
    t.datetime "confirmed_at"
    t.datetime "dispatched_at"
    t.datetime "delivered_at"
    t.datetime "received_at"
    t.datetime "cancelled_at"
    t.string "bill_number", limit: 50
    t.decimal "tax_amount", precision: 10, scale: 2, null: false
    t.integer "delivery_charge", null: false
    t.integer "packing_charge", null: false
    t.decimal "total_bill_amount", precision: 10, scale: 2, null: false
    t.string "status", limit: 20, default: "Placed", null: false
    t.string "payment_mode", limit: 50, null: false
    t.string "payment_status", limit: 20, default: "Pending", null: false
    t.string "special_request", limit: 200
    t.integer "eta_after_confirm"
    t.string "cancel_reason", limit: 50
    t.string "customer_mobile", limit: 15, null: false
    t.string "customer_address", limit: 500, null: false
    t.string "customer_locality"
    t.decimal "customer_latitude", precision: 17, scale: 15
    t.decimal "customer_longitude", precision: 18, scale: 15
    t.string "customer_name", limit: 50, null: false
    t.string "remarks", limit: 200
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["oid"], name: "index_orders_on_oid", unique: true
    t.index ["restaurant_id"], name: "index_orders_on_restaurant_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "restaurant_blacklistings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "restaurant_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["restaurant_id", "user_id"], name: "index_restaurant_blacklistings_on_restaurant_id_and_user_id", unique: true
    t.index ["restaurant_id"], name: "index_restaurant_blacklistings_on_restaurant_id"
    t.index ["user_id"], name: "index_restaurant_blacklistings_on_user_id"
  end

  create_table "restaurants", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "status", limit: 10, default: "Active", null: false
    t.string "description", limit: 100
    t.boolean "open_for_delivery_now", default: true
    t.integer "min_delivery_amount", default: 0
    t.integer "avg_delivery_time", default: 45
    t.integer "delivery_charge", default: 0
    t.integer "packing_charge", default: 0
    t.decimal "tax_percent", precision: 4, scale: 2, default: "0.0"
    t.decimal "rating", precision: 5, scale: 4
    t.string "rid", limit: 10
    t.string "phone_number", limit: 15
    t.string "locality", limit: 100
    t.string "address", limit: 200
    t.decimal "latitude", precision: 17, scale: 15
    t.decimal "longitude", precision: 18, scale: 15
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "owner_id"
    t.index ["name", "locality"], name: "index_restaurants_on_name_and_locality", unique: true
    t.index ["rid"], name: "index_restaurants_on_rid", unique: true
  end

  create_table "restaurants_cuisines", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "restaurant_id"
    t.bigint "cuisine_id"
    t.index ["cuisine_id"], name: "index_restaurants_cuisines_on_cuisine_id"
    t.index ["restaurant_id", "cuisine_id"], name: "index_restaurants_cuisines_on_restaurant_id_and_cuisine_id", unique: true
    t.index ["restaurant_id"], name: "index_restaurants_cuisines_on_restaurant_id"
  end

  create_table "roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "name", default: "", null: false
    t.string "mobile", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "uid"
    t.string "status", limit: 10, default: "Active", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  create_table "users_roles", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

end
