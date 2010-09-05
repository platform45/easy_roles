$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'active_record'
require 'easy_roles'

require 'spec'
require 'spec/autorun'


Spec::Runner.configure do |config|
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :serialize_users do |t|
      t.string :name
      t.string :roles, :default => "--- []"
    end
    create_table :bitmask_users do |t|
      t.string :name
      t.integer :roles_mask, :default => 0
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

setup_db

class SerializeUser < ActiveRecord::Base
  easy_roles :roles, :method => :serialize
end

class BitmaskUser < ActiveRecord::Base
  easy_roles :roles_mask, :method => :bitmask
  
  ROLES_MASK = %w[admin manager user]
end
