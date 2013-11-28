require 'spec_helper'

describe ArticlesController do
  before do
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    @controller.stub(:current_ability).and_return(@ability)
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
          articles.stub(:in_blogs_selected_by).with(user).and_return selected_articles = double
          get :index, selected_blogs: 'on'
          assigns[:articles].should == selected_articles
        end
      end

      context 'visitor' do
        it 'does not search in selected blogs' do
          articles.should_receive(:in_blogs_selected_by).never
          get :index, selected_blogs: 'on'
        end
      end
    end
  end


  describe '#show' do
    before do
      User.stub(:find_by_id).with('1').and_return @user = stub('user').as_null_object
      Article.stub(:find).with('1').and_return @article = stub('article').as_null_object
      @article.stub_chain(:threaded_comments, :page).with('1').and_return @comments = stub('comments')
      get :show, user_id: 1, id: 1, page: 1
    end

    it { should assign_to(:user).with @user }
    it { should assign_to(:article).with @article }
    it { should assign_to(:comments).with @comments }
  end

  describe '#new' do
    include_context 'authenticated user'

    before do
      @ability.can :create, Article
      get :new
    end

    it { assigns[:article].should be_instance_of Article }
    it { should render_template :new }
  end

  describe '#create' do
    include_context 'authenticated user'

    before do
      @current_user.stub_chain(:articles, :build).with('params').and_return @article = stub_model(Article)
      @ability.can :create, Article
    end

    def do_request(args = {})
      post :create, { article: 'params' }.merge(args)
    end

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

      it { should redirect_to user_article_path(@current_user, @article) }
      it { flash[:notice].should == 'The article has been created' }
    end

    context 'with invalid parameters' do
      before do
        @article.stub(:save).and_return false
        do_request
      end

      it { flash[:alert].should == 'The article has not been created' }
      it { should render_template 'articles/new' }
    end
  end

  describe '#edit' do
    include_context 'authenticated user'

    before do
      Article.stub(:find).with('1').and_return @article = stub_model(Article)
      @ability.can :edit, @article
      get :edit, id: 1
    end

    it { should assign_to(:article).with @article }


    it { should render_template :edit }
  end

  describe '#update' do
    include_context 'authenticated user'

    before do
      @article = stub_model(Article, user: @current_user)
      Article.stub(:find).with('1').and_return @article
      @ability.can :update, @article
    end

    def do_request(args = {})
      put :update, { id: 1 }.merge(args)
    end

    it 'assigns the @article' do
      do_request
      assigns[:article].should == @article
    end


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

      it { should redirect_to user_article_path(@current_user, @article) }
      it { flash[:notice].should == 'The article has been updated' }
    end

    context 'with invalid params' do
      before do
        @article.stub(:update_attributes).with('params').and_return false
        do_request article: 'params'
      end

      it { flash[:alert].should == 'The article has not been updated' }
      it { response.should render_template :edit }
    end
  end

  describe '#destroy' do
    include_context 'authenticated user'

    before do
      @article = stub_model(Article, user: @current_user)
      @article.stub(:destroy)
      Article.stub(:find).with('1').and_return @article
      @ability.can :destroy, @article
      @article.should_receive :destroy

      delete :destroy, id: 1
    end

    it { flash[:notice].should == 'The article has been deleted' }
    it { should redirect_to user_articles_path(@current_user) }
  end
end
