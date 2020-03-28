class CreateAppRoles < ActiveRecord::Migration[6.0]
  def up
    %w(admin restaurant customer).each do |role_name|
      Role.create! name: role_name
    end
  end
  def down
    Role.where(name: %w(admin restaurant customer)).destroy_all
  end
end
