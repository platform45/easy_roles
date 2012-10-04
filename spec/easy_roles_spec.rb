require 'spec_helper'

describe EasyRoles do
  describe "serialize method" do
    it "should allow me to set a users role" do
      user = SerializeUser.new
      user.add_role 'admin'
      user.roles.include?("admin").should be_true
    end

    it "should return true for is_admin? if the admin role is added to the user" do
      user = SerializeUser.new
      user.add_role 'admin'
      user.is_admin?.should be_true
    end

    it "should return true for has_role? 'admin' if the admin role is added to the user" do
      user = SerializeUser.new
      user.add_role 'admin'
      user.has_role?('admin').should be_true
    end

    it "should turn false for has_role? 'manager' if manager role is not added to the user" do
      user = SerializeUser.new
      user.has_role?('manager').should be_false
    end

    it "should turn false for is_manager? if manager role is not added to the user" do
      user = SerializeUser.new
      user.is_manager?.should be_false
    end

    it "should return the users role through association" do
      user = BitmaskUser.create(name: 'Bob')
      user.add_role! "admin"

      membership = Membership.create(name: 'Test Membership', bitmask_user: user)

      Membership.last.bitmask_user.is_admin?.should be_true
    end

    it "should get no method error if no easy roles on model" do
      begin
      b = Beggar.create(name: 'Ivor')

      b.is_admin?
      rescue => e
        e.class.should == NoMethodError
      end
    end

    it "should get no method error if no easy roles on model even through association" do
      begin
      b = Beggar.create(name: 'Ivor')
      m = Membership.create(name: 'Beggars club', beggar: b)

      Membership.last.beggar.is_admin?
      rescue => e
        e.class.should == NoMethodError
      end
    end

    describe "normal methods" do
      it "should not save to the database if not implicitly saved" do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.reload

        user.is_admin?.should be_false
      end

      it "should save to the database if implicity saved" do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload

        user.is_admin?.should be_true
      end

      it "should clear all roles and not save if not implicitly saved" do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload
        user.is_admin?.should be_true

        user.clear_roles
        user.is_admin?.should be_false
        user.reload

        user.is_admin?.should be_true
      end

      it "should clear all roles and save if implicitly saved" do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload
        user.is_admin?.should be_true

        user.clear_roles
        user.is_admin?.should be_false
        user.save
        user.reload

        user.is_admin?.should be_false
      end

      it "should remove a role and not save unless implicitly saved" do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload

        user.is_admin?.should be_true
        user.remove_role 'admin'
        user.is_admin?.should be_false
        user.reload

        user.is_admin?.should be_true
      end

      it "should remove a role and save if implicitly saved" do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload

        user.is_admin?.should be_true
        user.remove_role 'admin'
        user.is_admin?.should be_false
        user.save
        user.reload

        user.is_admin?.should be_false
      end
    end

    describe "bang method" do
      it "should save to the database if the bang method is used" do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role! 'admin'
        user.is_admin?.should be_true
        user.reload

        user.is_admin?.should be_true
      end

      it "should remove a role and save" do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload

        user.is_admin?.should be_true
        user.remove_role! 'admin'
        user.is_admin?.should be_false
        user.reload

        user.is_admin?.should be_false
      end
    end

    describe "scopes" do
      describe "with_role" do
        it "should implement the `with_role` scope" do
          SerializeUser.respond_to?(:with_role).should be_true
        end

        it "should return an ActiveRecord::Relation" do
          SerializeUser.with_role('admin').class.should == ActiveRecord::Relation
        end

        it "should match records for a given role" do
          user = SerializeUser.create(name: 'Daniel')
          SerializeUser.with_role('admin').include?(user).should be_false
          user.add_role! 'admin'
          SerializeUser.with_role('admin').include?(user).should be_true
        end

        it "should be chainable" do
          (daniel = SerializeUser.create(name: 'Daniel')).add_role! 'user'
          (ryan = SerializeUser.create(name: 'Ryan')).add_role! 'user'
          ryan.add_role! 'admin'
          admin_users = SerializeUser.with_role('user').with_role('admin')
          admin_users.include?(ryan).should be_true
          admin_users.include?(daniel).should be_false

          expect do
            admin_users = SerializeUser.with_role('user').with_role('admin').count
          end.to_not raise_error
        end

        it "should prove that wrapper markers are a necessary strategy by failing without them" do
          marker_cache = SerializeUser::ROLES_MARKER
          SerializeUser::ROLES_MARKER = ''
          (morgan = SerializeUser.create(name: 'Mr. Freeman')).add_role!('onrecursionrecursi')
          SerializeUser.with_role('recursion').include?(morgan).should be_true
          SerializeUser::ROLES_MARKER = marker_cache
        end

        it "should avoid incorrectly matching roles where the name is a subset of another role's name" do
          (chuck = SerializeUser.create(name: 'Mr. Norris')).add_role!('recursion')
          (morgan = SerializeUser.create(name: 'Mr. Freeman')).add_role!('onrecursionrecursi')
          SerializeUser.with_role('recursion').include?(chuck).should be_true
          SerializeUser.with_role('recursion').include?(morgan).should be_false
        end

        it "should not allow roles to be added if they include the ROLES_MARKER character" do
          marker_cache = SerializeUser::ROLES_MARKER
          SerializeUser::ROLES_MARKER = '!'
          user = SerializeUser.create(name: 'Towelie')
          user.add_role!('funkytown!').should be_false
          SerializeUser::ROLES_MARKER = marker_cache
        end

        it "should correctly handle markers on failed saves" do
          the_king = UniqueSerializeUser.create(name: 'Elvis')
          (imposter = UniqueSerializeUser.create(name: 'Elvisbot')).add_role!('sings-like-a-robot')
          imposter.name = 'Elvis'
          imposter.save.should be_false
          imposter.roles.any? {|r| r.include?(SerializeUser::ROLES_MARKER) }.should be_false
        end

      end
    end
  end

  describe "bitmask method" do
    it "should allow me to set a users role" do
      user = BitmaskUser.new
      user.add_role 'admin'
      user._roles.include?("admin").should be_true
    end

    it "should return true for is_admin? if the admin role is added to the user" do
      user = BitmaskUser.new
      user.add_role 'admin'
      user.is_admin?.should be_true
    end

    it "should return true for has_role? 'admin' if the admin role is added to the user" do
      user = BitmaskUser.new
      user.add_role 'admin'
      user.has_role?('admin').should be_true
    end

    it "should turn false for has_role? 'manager' if manager role is not added to the user" do
      user = BitmaskUser.new
      user.has_role?('manager').should be_false
    end

    it "should turn false for is_manager? if manager role is not added to the user" do
      user = BitmaskUser.new
      user.is_manager?.should be_false
    end

    it "should not allow you to add a role not in the array list of roles" do
      user = BitmaskUser.new
      user.add_role 'lolcat'
      user.is_lolcat?.should be_false
    end

    describe "normal methods" do
      it "should not save to the database if not implicitly saved" do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.reload

        user.is_admin?.should be_false
      end

      it "should save to the database if implicity saved" do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload

        user.is_admin?.should be_true
      end

      it "should clear all roles and not save if not implicitly saved" do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload
        user.is_admin?.should be_true

        user.clear_roles
        user.is_admin?.should be_false
        user.reload

        user.is_admin?.should be_true
      end

      it "should clear all roles and save if implicitly saved" do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload
        user.is_admin?.should be_true

        user.clear_roles
        user.is_admin?.should be_false
        user.save
        user.reload

        user.is_admin?.should be_false
      end

      it "should remove a role and not save unless implicitly saved" do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload

        user.is_admin?.should be_true
        user.remove_role 'admin'
        user.is_admin?.should be_false
        user.reload

        user.is_admin?.should be_true
      end

      it "should remove a role and save if implicitly saved" do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload

        user.is_admin?.should be_true
        user.remove_role 'admin'
        user.is_admin?.should be_false
        user.save
        user.reload

        user.is_admin?.should be_false
      end
    end

    describe "bang method" do
      it "should save to the database if the bang method is used" do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role! 'admin'
        user.is_admin?.should be_true
        user.reload

        user.is_admin?.should be_true
      end

      it "should remove a role and save" do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload

        user.is_admin?.should be_true
        user.remove_role! 'admin'
        user.is_admin?.should be_false
        user.reload

        user.is_admin?.should be_false
      end

      it "should clear all roles and save" do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload
        user.is_admin?.should be_true

        user.clear_roles!
        user.is_admin?.should be_false
        user.reload

        user.is_admin?.should be_false
      end
    end

    describe "scopes" do
      describe "with_role" do
        it "should implement the `with_role` scope" do
          BitmaskUser.respond_to?(:with_role).should be_true
        end

        it "should return an ActiveRecord::Relation" do
          BitmaskUser.with_role('admin').class.should == ActiveRecord::Relation
        end

        it "should raise an ArgumentError for undefined roles" do
          expect { BitmaskUser.with_role('your_mom') }.should raise_error(ArgumentError)
        end

        it "should match records with a given role" do
          user = BitmaskUser.create(name: 'Daniel')
          BitmaskUser.with_role('admin').include?(user).should be_false
          user.add_role! 'admin'
          BitmaskUser.with_role('admin').include?(user).should be_true
        end

        it "should be chainable" do
          (daniel = BitmaskUser.create(name: 'Daniel')).add_role! 'user'
          (ryan = BitmaskUser.create(name: 'Ryan')).add_role! 'user'
          ryan.add_role! 'admin'
          admin_users = BitmaskUser.with_role('user').with_role('admin')
          admin_users.include?(ryan).should be_true
          admin_users.include?(daniel).should be_false
        end
      end
    end

  end

  describe "symbol support" do
    # For class Serialize & Bitmask
    # Only add_role, remove_role, has_role and with_role methods are affected
    # And other methods are dependent on them, no need to test

    context "on serialize method" do
      describe "#add_role" do
        it "should convert symbol to string before storage" do
          user = SerializeUser.new
          user.add_role :admin
          user.roles.include?("admin").should be_true
        end
      end

      describe "#has_role" do
        it "should convert symbol to string before comparison" do
          user = SerializeUser.new
          user.add_role 'admin'
          user.roles.include?("admin").should be_true # To be sure

          user.has_role?(:admin).should be_true
        end
      end

      describe "#remove_role" do
        it "should convert symbol to string before removal" do
          user = SerializeUser.create(name: 'Ryan')
          user.add_role 'admin'
          user.roles.include?("admin").should be_true

          user.remove_role :admin
          user.roles.include?("admin").should be_false
        end
      end

      describe "#with_role" do
        it "should convert symbol to string before searching" do
          user = SerializeUser.create(name: 'Daniel')
          SerializeUser.with_role(:admin).should_not include(user)
          user.add_role! 'admin'
          SerializeUser.with_role(:admin).should include(user)
        end
      end

    end

    context "on bitmask method" do
      describe "#add_role" do
        it "should convert symbol to string before storage" do
          user = BitmaskUser.new
          user.add_role :admin
          user._roles.include?("admin").should be_true
        end
      end

      describe "#has_role" do
        it "should convert symbol to string before comparison" do
          user = BitmaskUser.new
          user.add_role 'admin'
          user._roles.include?("admin").should be_true # To be sure

          user.has_role?(:admin).should be_true
        end
      end

      describe "#remove_role" do
        it "should convert symbol to string before removal" do
          user = BitmaskUser.create(name: 'Ryan')
          user.add_role 'admin'
          user._roles.include?("admin").should be_true

          user.remove_role :admin
          user._roles.include?("admin").should be_false
        end
      end

      describe "#with_role" do
        it "should convert symbol to string before searching" do
          user = BitmaskUser.create(name: 'Daniel')
          BitmaskUser.with_role(:admin).should_not include(user)
          user.add_role! 'admin'
          BitmaskUser.with_role(:admin).should include(user)
        end
      end

    end
  end
end
