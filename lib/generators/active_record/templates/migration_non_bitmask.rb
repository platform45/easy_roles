class AddEasyRolesTo<%= table_name.camelize %> < ActiveRecord::Migration
  def change
    change_table :<%= table_name %> do |t|
      t.string :<%= self.role_col %>, default: '--- []'
      <% if options.add_index %>
        t.index :<%= self.role_col %>
      <% end %>
    end
  end
end
