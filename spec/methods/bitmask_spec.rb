# frozen_string_literal: true

require 'spec_helper'

describe EasyRoles do

  describe 'bitmask method' do
    it 'should allow me to set a users role' do
      user = BitmaskUser.new
      user.add_role 'admin'
      expect(user.roles). to include 'admin'
    end

    it 'should allow me to set multiple roles at one time' do
      user = BitmaskUser.new
      user.add_roles 'admin', 'manager'
      expect(user.roles).to include 'admin'
      expect(user.roles).to include 'manager'
      expect(user.roles.length).to eq 2
      user.add_roles 'admin', 'manager','user'
      expect(user.roles).to include 'user'
      expect(user.roles.length).to eq 3
    end

    it 'should return true for is_admin? if the admin role is added to the user' do
      user = BitmaskUser.new
      user.add_role 'admin'
      expect(user.is_admin?).to eq(true)
    end

    it "should return true for has_role? 'admin' if the admin role is added to the user" do
      user = BitmaskUser.new
      user.add_role 'admin'
      expect(user.has_role?('admin')).to eq(true)
    end

    it "should turn false for has_role? 'manager' if manager role is not added to the user" do
      user = BitmaskUser.new
      expect(user.has_role?('manager')).to eq(false)
    end

    it 'should turn false for is_manager? if manager role is not added to the user' do
      user = BitmaskUser.new
      expect(user.is_manager?).to eq(false)
    end

    it 'should not allow you to add a role not in the array list of roles' do
      user = BitmaskUser.new
      user.add_role 'lolcat'
      expect(user.is_lolcat?).to eq(false)
    end

    it 'should only add valid roles when adding multiple roles' do
      user = BitmaskUser.new
      user.add_roles 'admin', 'manager', 'lolcat'
      expect(user.roles.length).to eq 2
      expect(user.roles).to include 'admin'
      expect(user.roles).to include 'manager'
    end

    describe 'normal methods' do
      it 'should not save to the database if not implicitly saved' do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq(true)
        user.reload

        expect(user.is_admin?).to eq(false)
      end

      it 'should save to the database if implicity saved' do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq(true)
        user.save
        user.reload

        expect(user.is_admin?).to eq(true)
      end

      it 'should clear all roles and not save if not implicitly saved' do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq(true)
        user.save
        user.reload
        expect(user.is_admin?).to eq(true)

        user.clear_roles
        expect(user.is_admin?).to eq(false)
        user.reload

        expect(user.is_admin?).to eq(true)
      end

      it 'should clear all roles and save if implicitly saved' do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq(true)
        user.save
        user.reload
        expect(user.is_admin?).to eq(true)

        user.clear_roles
        expect(user.is_admin?).to eq(false)
        user.save
        user.reload

        expect(user.is_admin?).to eq(false)
      end

      it 'should remove a role and not save unless implicitly saved' do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq(true)
        user.save
        user.reload

        expect(user.is_admin?).to eq(true)
        user.remove_role 'admin'
        expect(user.is_admin?).to eq(false)
        user.reload

        expect(user.is_admin?).to eq(true)
      end

      it 'should remove a role and save if implicitly saved' do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq(true)
        user.save
        user.reload

        expect(user.is_admin?).to eq(true)
        user.remove_role 'admin'
        expect(user.is_admin?).to eq(false)
        user.save
        user.reload

        expect(user.is_admin?).to eq(false)
      end
    end

    describe 'bang method' do
      it 'should save to the database if the bang method is used' do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role! 'admin'
        expect(user.is_admin?).to eq(true)
        user.reload

        expect(user.is_admin?).to eq(true)
      end

      it 'should allow me to set multiple roles at one time' do
        user = BitmaskUser.new
        user.add_roles! 'admin', 'manager'
        expect(user.roles).to include 'admin'
        expect(user.roles).to include 'manager'
        expect(user.roles.length).to eq 2
        user.add_roles! 'admin', 'manager','user'
        expect(user.roles).to include 'user'
        expect(user.roles.length).to eq 3
      end

      it 'should remove a role and save' do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq(true)
        user.save
        user.reload

        expect(user.is_admin?).to eq(true)
        user.remove_role! 'admin'
        expect(user.is_admin?).to eq(false)
        user.reload

        expect(user.is_admin?).to eq(false)
      end

      it 'should clear all roles and save' do
        user = BitmaskUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq(true)
        user.save
        user.reload
        expect(user.is_admin?).to eq(true)

        user.clear_roles!
        expect(user.is_admin?).to eq(false)
        user.reload

        expect(user.is_admin?).to eq(false)
      end
    end

    describe 'scopes' do
      describe 'with_role' do
        it 'should implement the `with_role` scope' do
          expect(BitmaskUser).to respond_to :with_role
        end

        it 'should return an ActiveRecord::Relation' do
          expect(BitmaskUser.with_role('admin').class).to eq(
            "BitmaskUser::ActiveRecord_Relation".constantize
          )
        end

        it 'should raise an ArgumentError for undefined roles' do
          expect { BitmaskUser.with_role('your_mom') }.to raise_error(ArgumentError)
        end

        it 'should match records with a given role' do
          user = BitmaskUser.create(name: 'Daniel')
          expect(BitmaskUser.with_role('admin')).not_to include user
          user.add_role! 'admin'
          expect(BitmaskUser.with_role('admin')).to include user
        end

        it 'should be chainable' do
          (daniel = BitmaskUser.create(name: 'Daniel')).add_role! 'user'
          (ryan = BitmaskUser.create(name: 'Ryan')).add_role! 'user'
          ryan.add_role! 'admin'
          admin_users = BitmaskUser.with_role('user').with_role('admin')
          expect(admin_users).to include ryan
          expect(admin_users).not_to include daniel
        end
      end

      describe 'without_role' do
        it 'should implement the `without_role` scope' do
          expect(BitmaskUser).to respond_to :without_role
        end

        it 'should return an ActiveRecord::Relation' do
          expect(BitmaskUser.without_role('admin').class).to eq(
            "BitmaskUser::ActiveRecord_Relation".constantize
          )
        end

        it 'should raise an ArgumentError for undefined roles' do
          expect { BitmaskUser.without_role('your_mom') }.to raise_error(ArgumentError)
        end

        it 'should match records with a given role' do
          user = BitmaskUser.create(name: 'Daniel')
          expect(BitmaskUser.without_role('admin')).to include user
          user.add_role! 'admin'
          expect(BitmaskUser.without_role('admin')).not_to include user
        end

        it 'should be chainable' do
          (daniel = BitmaskUser.create(name: 'Daniel')).add_role! 'user'
          (ryan = BitmaskUser.create(name: 'Ryan')).add_role! 'user'
          ryan.add_role! 'admin'
          non_admin_users = BitmaskUser.with_role('user').without_role('admin')
          expect(non_admin_users).not_to include ryan
          expect(non_admin_users).to include daniel
        end
      end
    end
  end
end
