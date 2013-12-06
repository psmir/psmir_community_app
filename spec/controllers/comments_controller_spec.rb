require 'spec_helper'
require 'my_exceptions'

describe CommentsController do

  include_context 'authenticated user'

  describe 'GET #new' do
    before do
      Article.stub(:find).with('1').and_return @article = stub('article')
      get :new, article_id: 1
    end

    it { should assign_to(:resource).with(@article)}
    it { assigns[:comment].should be_a_new Comment }
    it { should render_template :new }
  end

  describe 'POST #create' do

    before do
      Article.stub(:find).and_return @article = stub_model(Article, user: mock_model(User))
      controller.stub(:current_user).and_return @current_user = stub_model(User)
      @comment = stub('comment').as_null_object
      Comment.stub(:build_from).with(@article, @current_user.id, 'some content').and_return @comment
    end

    def do_request(args = {})
      post :create, { article_id: 1, comment: { :body => 'some content' } }.merge(args)
    end

    it 'finds the resource' do
      do_request
      should assign_to(:resource).with(@article)
    end

    it 'creates a new comment and assigns it to the @comment' do
      do_request
      assigns[:comment].should == @comment
    end

    context 'with valid comment' do
      before do
        @comment.stub(:save).and_return true
        do_request
      end

      it 'sets a message that comment has been created' do
        flash[:notice].should == 'The comment has been created'
      end

      it 'redirects to the article page' do
        response.should redirect_to article_path(@article)
      end
    end

    context 'with invalid comment' do
      before do
        @comment.stub(:save).and_return false
        do_request
      end

      it 'sets a message that the comment has not been created' do
        flash[:alert].should == 'The comment has not been created'
      end

      it 'renders the :new template' do
        response.should render_template :new
      end
    end

    context 'without the comment parameter' do
      before do
        do_request comment: nil
      end

      it { assigns[:comment].should be_a_new Comment }
      it { should render_template :new }

    end

    context 'attaching the comment to its parent one' do
      it 'attaches when the parent id is received' do
        @comment.should_receive(:attach_to_comment_with_id).with('1')
        do_request parent: 1
      end

      it 'does not attach when the parent_id is not received' do
        @comment.should_receive(:attach_to_comment_with_id).never
        do_request
      end

      describe 'handling the <ParentCommentNotFound> exception' do
        before do
          @comment.stub(:attach_to_comment_with_id).and_raise(
            MyExceptions::ParentCommentNotFound.new('The parent comment was not found') )

          do_request parent: 1
        end

        it 'sets a message that the parent comment was not found' do
          flash[:alert].should == 'The parent comment was not found'
        end

        it 'redirects to the article page' do
          response.should redirect_to article_path(@article)
        end

      end
    end
  end
end
