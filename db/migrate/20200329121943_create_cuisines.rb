class CreateCuisines < ActiveRecord::Migration[6.0]
  def change
    create_table :cuisines do |t|
      t.string 'name', limit: 20, null: false
      t.string 'status', limit: 10, default: 'Active', null: false
      t.string 'description', limit: 100

      t.timestamps
    end
    add_index :cuisines, :name, unique: true
  end
end
