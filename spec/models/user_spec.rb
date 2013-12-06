require 'spec_helper'
require "cancan/matchers"

describe User do
  describe "abilities" do
    subject { Ability.new(user) }

    context "admin" do
      let(:user){ FactoryGirl.create(:user, admin: true) }

      it { should be_able_to(:manage, :all) }
    end

    context "user" do
      let(:user){ FactoryGirl.create(:user) }
      it { should be_able_to(:read, Article.new) }
      it { should be_able_to(:manage, FactoryGirl.create(:article, user: user)) }
      it { should_not be_able_to(:manage, Article.new) }
      it { should be_able_to(:read, FactoryGirl.create(:message, recipient: user)) }
      it { should be_able_to(:create, FactoryGirl.create(:message, sender: user)) }
      it { should be_able_to(:destroy, FactoryGirl.create(:message, recipient: user)) }
    end
  end

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
