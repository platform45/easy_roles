$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'active_record'
require 'easy_roles'

RSpec.configure do |config|
end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

def setup_db
  ActiveRecord::Schema.define(version: 1) do
    create_table :serialize_users do |t|
      t.string :name
      t.string :roles, default: "--- []"
    end
    create_table :bitmask_users do |t|
      t.string :name
      t.integer :roles_mask, default: 0
    end
    
    create_table :memberships do |t|
      t.string :name
      t.integer :bitmask_user_id
      t.integer :beggar_id
    end
    
    create_table :beggars do |t|
      t.string :name
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
  easy_roles :roles, method: :serialize
end

class UniqueSerializeUser < SerializeUser
  validates :name, uniqueness: true
end

class BitmaskUser < ActiveRecord::Base
  has_many :memberships
  easy_roles :roles_mask, method: :bitmask
  
  ROLES_MASK = %w[admin manager user]
end

class Membership < ActiveRecord::Base
  belongs_to :bitmask_user
  belongs_to :beggar
end

class Beggar < ActiveRecord::Base
  has_many :memberships
end
