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
      user = BitmaskUser.create(:name => "Bob")
      user.add_role! "admin"
      
      membership = Membership.create(:name => "Test Membership", :bitmask_user => user)
      
      Membership.last.bitmask_user.is_admin?.should be_true
    end
    
    it "should get no method error if no easy roles on model" do
      begin
      b = Beggar.create(:name => "Ivor")
      
      b.is_admin?
      rescue => e
        e.class.should == NoMethodError
      end
    end
    
    it "should get no method error if no easy roles on model even through association" do
      begin
      b = Beggar.create(:name => "Ivor")
      m = Membership.create(:name => "Beggars club", :beggar => b)
      
      Membership.last.beggar.is_admin?
      rescue => e
        e.class.should == NoMethodError
      end
    end
    
    describe "normal methods" do
      it "should not save to the database if not implicitly saved" do
        user = SerializeUser.create(:name => "Ryan")
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.reload
      
        user.is_admin?.should be_false
      end
    
      it "should save to the database if implicity saved" do
        user = SerializeUser.create(:name => "Ryan")
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload
      
        user.is_admin?.should be_true
      end
      
      it "should clear all roles and not save if not implicitly saved" do
        user = SerializeUser.create(:name => "Ryan")
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
        user = SerializeUser.create(:name => "Ryan")
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
        user = SerializeUser.create(:name => "Ryan")
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
        user = SerializeUser.create(:name => "Ryan")
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
        user = SerializeUser.create(:name => "Ryan")
        user.add_role! 'admin'
        user.is_admin?.should be_true
        user.reload
      
        user.is_admin?.should be_true
      end
      
      it "should remove a role and save" do
        user = SerializeUser.create(:name => "Ryan")
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
  end
  
  describe "bitmask method" do
    it "should allow me to set a users role" do
      user = BitmaskUser.new
      user.add_role 'admin'
      user.roles.include?("admin").should be_true
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
        user = BitmaskUser.create(:name => "Ryan")
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.reload
      
        user.is_admin?.should be_false
      end
    
      it "should save to the database if implicity saved" do
        user = BitmaskUser.create(:name => "Ryan")
        user.add_role 'admin'
        user.is_admin?.should be_true
        user.save
        user.reload
      
        user.is_admin?.should be_true
      end
      
      it "should clear all roles and not save if not implicitly saved" do
        user = BitmaskUser.create(:name => "Ryan")
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
        user = BitmaskUser.create(:name => "Ryan")
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
        user = BitmaskUser.create(:name => "Ryan")
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
        user = BitmaskUser.create(:name => "Ryan")
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
        user = BitmaskUser.create(:name => "Ryan")
        user.add_role! 'admin'
        user.is_admin?.should be_true
        user.reload
      
        user.is_admin?.should be_true
      end
      
      it "should remove a role and save" do
        user = BitmaskUser.create(:name => "Ryan")
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
        user = BitmaskUser.create(:name => "Ryan")
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
  end
end