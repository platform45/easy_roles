class AddBitmaskRolesTo<%= table_name.camelize %> < ActiveRecord::Migration
  def change
    change_table :<%= table_name %> do |t|
      t.integer :<%= self.role_col %>, default: 0
    end
  end
end
