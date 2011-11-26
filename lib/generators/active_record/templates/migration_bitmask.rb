class AddBitmaskRolesTo<%= table_name.camelize %> < ActiveRecord::Migration
  def self.up
    add_column :<%= table_name %>, :<%= self.role_col %>, :integer, default: 0
  end

  def self.down
    remove_column :<%= table_name.to_sym %>, :<%= self.role_col %>
  end
end
