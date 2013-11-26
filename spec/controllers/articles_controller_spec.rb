require 'spec_helper'

describe ArticlesController do

  shared_examples 'accessible for an owner of the article only' do
    context 'when the article does not belong to the current user' do
      before do
        @article = stub_model(Article, user: mock_model(User))
        Article.stub(:fetch).with('1').and_return @article
        Article.stub(:find).with('1').and_return @article
        do_request
      end

      it "redirects to the current user's blog" do
        response.should redirect_to user_articles_path(@current_user)
      end
    end
  end

  describe "#index" do
    let(:user) { stub_model(User) }
    let(:articles) { double('articles').as_null_object }

    before do
      Article.stub(:default_list).and_return articles
    end

    context "for user" do
      before do
        User.stub(:find_by_id).with('1').and_return user
      end

      it 'finds a user' do
        get :index, user_id: 1
        assigns[:user].should == user
      end

      it "finds user's articles" do
        user.stub_chain(:articles, :default_list).and_return articles
        get :index, user_id: 1
        assigns[:articles].should == articles
      end

    end

    it 'finds articles' do
      get :index
      assigns[:articles].should == articles
    end

    it 'paginates the articles list' do
      articles.should_receive(:page).with('1')
      get :index, page: 1
    end

    it 'finds the tag counts' do
      Article.stub(:tag_counts).and_return tag_counts = double
      get :index
      assigns[:tag_counts].should == tag_counts
    end

    it 'filters by tag' do
      CGI.stub(:unescape).with('escaped').and_return 'unescaped'
      articles.stub(:tagged_with).with('unescaped').and_return tagged_articles = double
      get :index, tag: 'escaped'
      assigns[:articles].should == tagged_articles
    end

    it 'filters by tag list' do
      articles.stub(:tagged_with).with('tag1, tag2').and_return tagged_articles = double
      get :index, query: 'tag1, tag2', mode: 'tags'
      assigns[:articles].should == tagged_articles
    end

    it 'filters by content' do
      articles.stub(:with_query).with('some query').and_return filtered_articles = double
      get :index, query: 'some query', mode: 'content'
      assigns[:articles].should == filtered_articles
    end

    context 'search in selected blogs' do
      context 'signed in user' do
        it 'searches in selected blogs' do
          controller.stub(:current_user).and_return user = double
          articles.stub(:in_selected_blogs).with(user).and_return selected_articles = double
          get :index, selected_blogs: 'on'
          assigns[:articles].should == selected_articles
        end
      end

      context 'visitor' do
        it 'does not search in selected blogs' do
          articles.should_receive(:in_selected_blogs).never
          get :index, selected_blogs: 'on'
        end
      end
    end
  end


  describe 'GET /users/:user_id/articles/:id (#show)' do
    before do
      User.stub(:find_by_id).with('1').and_return @user = stub('user').as_null_object
      Article.stub(:find).with('1').and_return @article = stub('article').as_null_object
    end

    def do_request(args = {})
      get :show, { user_id: 1, id: 1 }.merge(args)
    end

    it 'finds a user' do
      do_request
      assigns[:user].should eq @user
    end

    it 'finds an article' do
      do_request
      assigns[:article].should eq @article
    end



    it 'finds the comments of the article and paginates them' do
      @article.stub_chain(:threaded_comments, :page).with('1').and_return comments = stub('comments')
      do_request page: 1
      assigns[:comments].should == comments
    end
  end

  describe 'GET #new' do
    before do
      controller.stub :authenticate_user!
    end

    def do_request(args = {})
      get :new, args
    end

    it_behaves_like 'requiring authentication'

    it 'assigns a new Article instance to the @article' do
      Article.stub(:new).and_return :new_article
      do_request
      assigns[:article].should eq :new_article
    end

    it 'should render the template :new' do
      do_request
      response.should render_template :new
    end

  end

  describe 'POST #create' do
    include_context 'authenticated user'

    before do
      @current_user.stub_chain(:articles, :build).with('params').and_return @article = stub_model(Article)
    end

    def do_request(args = {})
      post :create, { article: 'params' }.merge(args)
    end

    it_behaves_like 'requiring authentication'

    it 'builds an article object and assigns it to the @article' do
      do_request
      assigns[:article].should == @article
    end

    it 'sets the tag_list' do
      do_request tags: 'tag1, tag2'
      @article.tag_list.should == ['tag1', 'tag2']
    end

    context 'with valid parameters' do
      before do
        @article.stub(:save).and_return true
        do_request
      end

      it 'redirects to the article page' do
        response.should redirect_to user_article_path(@current_user, @article)
      end

      it 'informs that a new article has been created' do
        flash[:notice].should == 'The article has been created'
      end
    end

    context 'with invalid parameters' do
      before do
        @article.stub(:save).and_return false
        do_request
      end

      it 'informs that an article has not been created' do
        flash[:alert].should == 'The article has not been created'
      end

      it 'renders the :new template' do
        response.should render_template 'articles/new'
      end
    end
  end

  describe 'GET #edit' do
    include_context 'authenticated user'

    before do
      Article.stub(:find).with('1').and_return @article = stub_model(Article, user: @current_user)
    end

    def do_request(args = {})
      get :edit, { id: 1 }.merge(args)
    end

    it_behaves_like 'requiring authentication'

    it 'finds an article and assigns it to the @article' do
      do_request
      assigns[:article].should == @article
    end

    it_behaves_like 'accessible for an owner of the article only'

    it 'renders the edit template' do
      do_request
      response.should render_template :edit
    end

  end

  describe 'PUT #update' do
    include_context 'authenticated user'

    before do
      @article = stub_model(Article, user: @current_user)
      Article.stub(:find).with('1').and_return @article
    end

    def do_request(args = {})
      put :update, { id: 1 }.merge(args)
    end

    it_behaves_like 'requiring authentication'

    it 'finds the article and assigns it to the @article' do
      do_request
      assigns[:article].should == @article
    end

    it_behaves_like 'accessible for an owner of the article only'

    it 'sets tag list of the article' do
      do_request tags: 'tag1, tag2'
      @article.tag_list.should == ['tag1', 'tag2']
    end

    it 'does not change the tag_list when the <tags> parameter is not received' do
      @article.tag_list = ['tag']
      do_request
      @article.tag_list.should == ['tag']
    end

    it 'updates the article' do
      @article.should_receive(:update_attributes).with('params')
      do_request article: 'params'
    end

    context 'with valid params' do
      before do
        @article.stub(:update_attributes).with('params').and_return true
        do_request article: 'params'
      end

      it 'redirects to the article page' do
        response.should redirect_to user_article_path(@current_user, @article)
      end

      it 'sets a message that the article has been updated' do
        flash[:notice].should == 'The article has been updated'
      end
    end

    context 'with invalid params' do
      before do
        @article.stub(:update_attributes).with('params').and_return false
        do_request article: 'params'
      end

      it 'sets message about fail' do
        flash[:alert].should == 'The article has not been updated'
      end

      it 'renders :edit template' do
        response.should render_template :edit
      end
    end

  end

  describe 'DELETE #destroy' do
    include_context 'authenticated user'

    before do
      controller.stub :render
      @article = stub_model(Article, user: @current_user)
      @article.stub(:destroy)
      Article.stub(:find).with('1').and_return @article
    end

    def do_request(args = {})
      delete :destroy, { id: 1 }.merge(args)
    end

    it_behaves_like 'requiring authentication'

    it 'finds the article and assigns it to the @article' do
      do_request
      assigns[:article].should == @article
    end

    it_behaves_like 'accessible for an owner of the article only'

    it 'deletes the article' do
      @article.should_receive :destroy
      do_request
    end

    it 'sets the message that the article is deleted' do
      do_request
      flash[:notice].should == 'The article has been deleted'
    end

    it "redirects to the current user's blog" do
      do_request
      response.should redirect_to user_articles_path(@current_user)
    end

  end

  shared_examples 'search page renderer' do

    it 'renders the :search template' do
      do_request
      response.should render_template 'articles/search'
    end

    it 'paginates articles list' do
      @articles.should_receive(:page).with('1')
      do_request page: 1
    end

    it 'assigns tag counts for tag cloud' do
      do_request
      assigns[:tag_counts].should eq 'tag_counts'
    end
  end

  context 'search articles' do
    before do
      @articles = stub('articles').as_null_object
      Article.stub(:tag_counts).and_return 'tag_counts'
    end

    describe 'GET #search' do
      before do
        Article.stub(:default_list).and_return @articles
      end

      def do_request(args = {})
        get :search, args
      end

      it 'returns default articles list' do
        do_request
        assigns[:articles].should eq @articles
      end

      it_should_behave_like 'search page renderer'
    end

    describe 'GET #search_by_tag' do
      before do
        CGI.stub(:unescape).with('unescaped').and_return 'escaped'
        Article.stub(:search_by_tag).with('escaped').and_return @articles
      end

      def do_request(args = {})
        get :search_by_tag, { tag: 'unescaped' }.merge(args)
      end

      it 'returns tagged articles' do
        do_request
        assigns[:articles].should eq @articles
      end

      it_should_behave_like 'search page renderer'
    end


    describe 'POST #search_by_query' do
      before do
        Article.stub(:search_by_query).with('query').and_return @articles
      end

      def do_request(args = {})
        post :search_by_query, { query: 'query', mode: 'content' }.merge(args)
      end

      it 'finds articles by relevance' do
        do_request
        assigns[:articles].should == @articles
      end

      it 'finds articles by tag list' do
        tagged_articles = stub('tagged articles').as_null_object
        Article.stub(:search_by_tag).with('tag1, tag2').and_return tagged_articles
        do_request query: 'tag1, tag2', mode: 'tags'
        assigns[:articles].should == tagged_articles
      end

      context 'when selected_blog parameter is received' do

        context 'signed in user' do
          include_context 'authenticated user'
          it 'selects articles from favorite blogs' do
            favorite_articles = stub('favorite articles').as_null_object
            @articles.stub(:in_blogs_selected_by).with(@current_user).and_return favorite_articles

            do_request selected_blogs: 'on'
            assigns[:articles].should == favorite_articles
          end

          context 'plain visitor' do
            before do
              controller.stub(:user_signed_in?).and_return false
            end

            it 'does not select from favorite blogs' do
              @articles.should_receive(:in_blogs_selected_by).never
              do_request selected_blogs: 'on'
            end
          end
        end
      end

      it 'redirects to the root page if the mode param is not the <content> or <tags>' do
        do_request mode: 'wrong'
        response.should redirect_to root_path
      end

      it_should_behave_like 'search page renderer'

      context 'via ajax' do
        it 'renders search.js template' do
          do_request format: 'js'
          response.should render_template 'search.js'
        end
      end

    end
  end
end
