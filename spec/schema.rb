ActiveRecord::Schema.define(:version => 0) do
  create_table :users, :force => true do |t|
    t.string :roles, :default => "--- []"
    t.integer :roles_mask, :default => 0
  end
end