require 'spec_helper'

describe User do
  
  describe 'mass assignment' do
    it { should_not allow_mass_assignment_of(:admin) }
  end

  describe 'validation' do
    before do
      @user = create_user! # for uniqueness checking
    end

    it { should validate_presence_of :username }
    it { should ensure_length_of(:username).is_at_most(30) }
    it { should validate_uniqueness_of :username }
  end

  describe '.fetch' do
    before do
      Rails.cache.clear
      @user = create_user!
    end

    it 'is not in the cache before the first .fetch call' do
      Rails.cache.fetch("user_#{@user.id}").should be_nil
    end

    it 'is in the cache after the .fetch call' do
      User.fetch(@user.id)
      Rails.cache.fetch("user_#{@user.id}").should eq @user
    end
  end  

 describe 'removing from the cache' do
    before do
      @user = create_user!
      User.fetch @user.id # the user is in cache now
    end

    it 'removes the user after save' do
      @user.save
      Rails.cache.fetch("user_#{@user.id}").should be_nil
    end

    it 'removes the user after destroy' do
      @user.destroy
      Rails.cache.fetch("user_#{@user.id}").should be_nil
    end
  end

  context '#follow/#unfollow' do
    before do
      @user = create_user!
      @blogger = create_user!
    end

    describe '#follow(blogger)' do
      it 'adds the blogger to the list of bloggers' do
        @user.follow @blogger
        @user.bloggers.should == [@blogger]
      end
    end

    describe '#unfollow(blogger)' do
      before do
        @user.bloggers << @blogger
      end

      it 'removes the blogger from the list of bloggers' do
        @user.unfollow @blogger
        @user.bloggers.should == []
      end
    end
  end
end