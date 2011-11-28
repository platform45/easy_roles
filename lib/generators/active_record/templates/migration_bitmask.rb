class AddBitmaskRolesTo<%= table_name.camelize %> < ActiveRecord::Migration
  def change
    change_table :<%= table_name %> do |t|
      t.integer :<%= self.role_col %>, default: 0
      <% if self.add_index %>
        t.index :<%= self.role_col %>
      <% end %>
    end
  end
end
