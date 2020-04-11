class MealSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :description,
             :status,
             :is_chef_special,
             :is_veg,
             :contains_egg,
             :contains_meat,
             :is_vegan,
             :is_halal,
             :course,
             :ingredients,
             :spice_level,
             :price,
             :serves,
             :created_at,
             :updated_at
  belongs_to :cuisine
end
