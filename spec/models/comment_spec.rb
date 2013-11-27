require 'spec_helper'
require 'my_exceptions'

describe Comment do

  describe 'mass assignment' do
    it { should_not allow_mass_assignment_of([:user_id, :parent_id, :level]) }
  end

  describe 'validation' do
    it { should validate_presence_of :body }
    it { should validate_presence_of :user }
  end

  describe '#attach_to_comment_with_id(id)' do
    before do
      @parent = stub_model Comment
      @child = stub_model Comment
    end

    context 'a parent with the id exists' do
      before do
        Comment.stub(:find).with(@parent.id).and_return @parent
      end

      context 'the parent has the same commentable_type' do
        before do
          @child.stub(:commentable_type).and_return 'Article'
          @parent.stub(:commentable_type).and_return 'Article'
          @parent.stub(:level).and_return 1
        end

        it 'sets parent_id to @parent.id' do
          @child.should_receive(:parent_id=).with(@parent.id)
          @child.attach_to_comment_with_id @parent.id
        end

        it 'sets the level to parent.level + 1' do
          @child.should_receive(:level=).with(2)
          @child.attach_to_comment_with_id @parent.id
        end
      end

      context 'the parent has a different commentable_type' do
        before do
          @child.stub(:commentable_type).and_return 'Article'
          @parent.stub(:commentable_type).and_return 'Profile'
        end

        it 'raises the ParentCommentNotFound exception' do
          expect {
            @child.attach_to_comment_with_id @parent.id
          }.to raise_error(MyExceptions::ParentCommentNotFound, 'The parent comment was not found')
        end
      end
    end

    context 'a comment with the id does not exist' do
      before do
        Comment.stub(:find).and_return nil
      end

      it 'raises the ParentCommentNotFound exception' do
        expect {
          @child.attach_to_comment_with_id @parent.id
        }.to raise_error(MyExceptions::ParentCommentNotFound, 'The parent comment was not found')
      end
    end
  end

end
