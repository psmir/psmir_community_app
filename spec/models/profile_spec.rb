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
