class SeedCuisines < ActiveRecord::Migration[6.0]
  def up
    %w(american chinese pizza italian indian japanese mexican thai korean lebanese).each do |name|
      Cuisine.create! name: name
    end
  end
  def down
    Cuisine.where(name: %w(american chinese pizza italian indian japanese mexican thai korean lebanese)).destroy_all
  end
end
