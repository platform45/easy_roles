# frozen_string_literal: true

require 'spec_helper'

describe EasyRoles do
  describe 'serialize method' do
    it 'should allow me to set a users role' do
      user = SerializeUser.new
      user.add_role 'admin'
      expect(user.roles).to include('admin')
    end

    it 'should allow me to set multiple roles at one time' do
      user = SerializeUser.new
      user.add_roles 'admin', 'manager'
      expect(user.roles).to include 'admin'
      expect(user.roles).to include 'manager'
      expect(user.roles.length).to eq 2
      user.add_roles 'admin', 'manager','user'
      expect(user.roles).to include 'user'
      expect(user.roles.length).to eq 3
    end

    it 'should return true for is_admin? if the admin role is added to the user' do
      user = SerializeUser.new
      user.add_role 'admin'
      expect(user.is_admin?).to eq true
    end

    it "should return true for has_role? 'admin' if the admin role is added to the user" do
      user = SerializeUser.new
      user.add_role 'admin'
      expect(user.has_role?('admin')).to eq true
    end

    it "should turn false for has_role? 'manager' if manager role is not added to the user" do
      user = SerializeUser.new
      expect(user.has_role?('manager')).to eq false
    end

    it 'should turn false for is_manager? if manager role is not added to the user' do
      user = SerializeUser.new
      expect(user.is_manager?).to eq false
    end

    it 'should return the users role through association' do
      user = BitmaskUser.create(name: 'Bob')
      user.add_role! 'admin'

      Membership.create(name: 'Test Membership', bitmask_user: user)

      expect(Membership.last.bitmask_user.is_admin?).to eq true
    end

    it 'should get no method error if no easy roles on model' do
      b = Beggar.create(name: 'Ivor')

      b.is_admin?
    rescue StandardError => e
      expect(e.class).to eq(NoMethodError)
    end

    it 'should get no method error if no easy roles on model even through association' do
      b = Beggar.create(name: 'Ivor')
      Membership.create(name: 'Beggars club', beggar: b)
      Membership.last.beggar.is_admin?

    rescue StandardError => e
      expect(e.class).to eq(NoMethodError)
    end

    describe 'normal methods' do
      it 'should not save to the database if not implicitly saved' do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq true
        user.reload

        expect(user.is_admin?).to eq false
      end

      it 'should save to the database if implicity saved' do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq true
        user.save
        user.reload

        expect(user.is_admin?).to eq true
      end

      it 'should clear all roles and not save if not implicitly saved' do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq true
        user.save
        user.reload
        expect(user.is_admin?).to eq true

        user.clear_roles
        expect(user.is_admin?).to eq false
        user.reload

        expect(user.is_admin?).to eq true
      end

      it 'should clear all roles and save if implicitly saved' do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq true
        user.save
        user.reload
        expect(user.is_admin?).to eq true

        user.clear_roles
        expect(user.is_admin?).to eq false
        user.save
        user.reload

        expect(user.is_admin?).to eq false
      end

      it 'should remove a role and not save unless implicitly saved' do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq true
        user.save
        user.reload

        expect(user.is_admin?).to eq true
        user.remove_role 'admin'
        expect(user.is_admin?).to eq false
        user.reload

        expect(user.is_admin?).to eq true
      end

      it 'should remove a role and save if implicitly saved' do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq true
        user.save
        user.reload

        expect(user.is_admin?).to eq true
        user.remove_role 'admin'
        expect(user.is_admin?).to eq false
        user.save
        user.reload

        expect(user.is_admin?).to eq false
      end
    end

    describe 'bang method' do
      it 'should save to the database if the bang method is used' do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role! 'admin'
        expect(user.is_admin?).to eq true
        user.reload

        expect(user.is_admin?).to eq true
      end

      it 'should allow me to set multiple roles at one time' do
        user = SerializeUser.new
        user.add_roles! 'admin', 'manager'
        expect(user.roles).to include 'admin'
        expect(user.roles).to include 'manager'
        expect(user.roles.length).to eq 2
        user.add_roles! 'admin', 'manager','user'
        expect(user.roles).to include 'user'
        expect(user.roles.length).to eq 3
      end

      it 'should remove a role and save' do
        user = SerializeUser.create(name: 'Ryan')
        user.add_role 'admin'
        expect(user.is_admin?).to eq true
        user.save
        user.reload

        expect(user.is_admin?).to eq true
        user.remove_role! 'admin'
        expect(user.is_admin?).to eq false
        user.reload

        expect(user.is_admin?).to eq false
      end
    end

    describe 'scopes' do
      describe 'with_role' do
        describe 'with markers' do
          before do
            @marker_cache = SerializeUser.roles_marker
          end

          after do
            SerializeUser.roles_marker = @marker_cache
          end

          it 'should prove that wrapper markers are a necessary strategy by failing without them' do
            SerializeUser.roles_marker = ''
            (morgan = SerializeUser.create(name: 'Mr. Freeman')).add_role!('onrecursionrecursi')
            expect(SerializeUser.with_role('recursion')).to include morgan
          end

          it 'should not allow roles to be added if they include the roles_marker character' do
            SerializeUser.roles_marker = '!'
            user = SerializeUser.create(name: 'Towelie')
            expect(user.add_role!('funkytown!')).to eq false
          end
        end

        it 'should implement the `with_role` scope' do
          expect(SerializeUser).to respond_to :without_role
        end

        it 'should return an ActiveRecord::Relation' do
          expect(SerializeUser.with_role('admin').class).to eq(
            "SerializeUser::ActiveRecord_Relation".constantize
          )
        end

        it 'should match records for a given role' do
          user = SerializeUser.create(name: 'Daniel')
          expect(SerializeUser.with_role('admin')).not_to include user

          user.add_role! 'admin'
          expect(SerializeUser.with_role('admin')).to include user
        end

        it 'should be chainable' do
          (daniel = SerializeUser.create(name: 'Daniel')).add_role! 'user'
          (ryan = SerializeUser.create(name: 'Ryan')).add_role! 'user'
          ryan.add_role! 'admin'
          admin_users = SerializeUser.with_role('user').with_role('admin')
          expect(admin_users).to include ryan
          expect(admin_users).not_to include daniel
        end

        it "should avoid incorrectly matching roles where the name is a subset of another role's name" do
          (chuck = SerializeUser.create(name: 'Mr. Norris')).add_role!('recursion')
          (morgan = SerializeUser.create(name: 'Mr. Freeman')).add_role!('onrecursionrecursi')
          expect(SerializeUser.with_role('recursion')).to include chuck
          expect(SerializeUser.with_role('recursion')).not_to include morgan
        end

        it 'should correctly handle markers on failed saves' do
          UniqueSerializeUser.create(name: 'Elvis')
          (imposter = UniqueSerializeUser.create(name: 'Elvisbot')).add_role!('sings-like-a-robot')
          imposter.name = 'Elvis'
          expect(imposter.save).to eq false
          expect(imposter.roles.any? { |r| r.include?(SerializeUser.roles_marker) }).to eq false
        end
      end

      describe 'without_role' do
        describe 'with markers' do
          before do
            @marker_cache = SerializeUser.roles_marker
          end

          after do
            SerializeUser.roles_marker = @marker_cache
          end

          it 'should prove that wrapper markers are a necessary strategy by failing without them' do
            SerializeUser.roles_marker = ''
            (morgan = SerializeUser.create(name: 'Mr. Freeman')).add_role!('onrecursionrecursi')
            expect(SerializeUser.without_role('onrecursionrecursi')).not_to include morgan
            expect(SerializeUser.without_role('recursion')).not_to include morgan
          end

          it 'should not allow roles to be added if they include the roles_marker character' do
            SerializeUser.roles_marker = '!'
            user = SerializeUser.create(name: 'Towelie')
            expect(user.add_role!('funkytown!')).to eq false
          end
        end

        it 'should implement the `without_role` scope' do
          expect(SerializeUser).to respond_to :without_role 
        end

        it 'should return an ActiveRecord::Relation' do
          expect(SerializeUser.without_role('admin').class).to eq(
            "SerializeUser::ActiveRecord_Relation".constantize
          )
        end

        it 'should match records for a given role' do
          user = SerializeUser.create(name: 'Daniel')
          expect(SerializeUser.without_role('admin')).to include user 
          user.add_role! 'admin'
          expect(SerializeUser.without_role('admin')).not_to include user
        end

        it 'should be chainable' do
          (daniel = SerializeUser.create(name: 'Daniel')).add_role! 'user'
          (ryan = SerializeUser.create(name: 'Ryan')).add_role! 'user'
          ryan.add_role! 'admin'
          non_admin_users = SerializeUser.with_role('user').without_role('admin')
          expect(non_admin_users).not_to include ryan
          expect(non_admin_users).to include daniel
        end

        it "should avoid incorrectly matching roles where the name is a subset of another role's name" do
          (chuck = SerializeUser.create(name: 'Mr. Norris')).add_role!('recursion')
          (morgan = SerializeUser.create(name: 'Mr. Freeman')).add_role!('onrecursionrecursi')

          expect(SerializeUser.without_role('onrecursionrecursi')).to include chuck
          expect(SerializeUser.without_role('onrecursionrecursi')).not_to include morgan
          expect(SerializeUser.without_role('recursion')).not_to include chuck
          expect(SerializeUser.without_role('recursion')).to include morgan
        end
      end
    end
  end
end