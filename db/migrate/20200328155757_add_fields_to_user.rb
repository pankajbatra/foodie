class AddFieldsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :uid, :string
    add_column :users, :status, :string, :limit => 10, :null => false, :default => 'Active'
    add_index :users, :uid, :unique => true
  end
end
