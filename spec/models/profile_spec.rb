require 'spec_helper'

describe Profile do
  describe 'validations' do 
    it { should validate_presence_of :name }
    it { should ensure_length_of(:name).is_at_most(50) }
    it { should allow_value('male').for(:gender) }
    it { should allow_value('female').for(:gender) }
    it { should_not allow_value('something').for(:gender) }
    it { should ensure_inclusion_of(:birthday).in_range((Date.new(1900, 1, 1))..(Date.today - 16.years)) }
  end

  describe '.fetch' do
    before do
      Rails.cache.clear
      @user = create_user!
    end

    it 'is not in the cache before the first .fetch call' do
      Rails.cache.fetch("profile_#{@user.profile.id}").should be_nil
    end

    it 'is in the cache after the .fetch call' do
      Profile.fetch(@user.profile.id)
      Rails.cache.fetch("profile_#{@user.profile.id}").should eq @user.profile
    end
  end  

  describe 'removing from the cache' do
    before do
      @user = create_user!
      @profile = Profile.fetch(@user.profile.id) #@profile is in the cache now
    end

    it 'removes the profile after save' do
      @profile.save
      Rails.cache.fetch("profile_#{@profile.id}").should be_nil
    end

    it 'removes the profile after destroy' do
      @profile.destroy
      Rails.cache.fetch("profile_#{@profile.id}").should be_nil
    end
  end

  describe '#get_avatar_file(style)' do
    before do
      @profile = Profile.new
    end

    it 'should fetch avatar_thumb_file if style is thumb' do
      @profile.stub(:avatar_thumb_file).and_return :avatar_thumb_file
      @profile.get_avatar_file('thumb').should == :avatar_thumb_file
    end

    it 'should fetch avatar_medium_file if style is medium' do
      @profile.stub(:avatar_medium_file).and_return :avatar_medium_file
      @profile.get_avatar_file('medium').should == :avatar_medium_file
    end

    it 'should fetch avatar_file field if no style parameter' do
      @profile.stub(:avatar_file).and_return :avatar_file
      @profile.get_avatar_file('original').should == :avatar_file
    end
  end
end
