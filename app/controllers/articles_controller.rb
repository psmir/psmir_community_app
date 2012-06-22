require 'cgi'
class ArticlesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :search, :search_by_tag, :search_by_query]
  before_filter :fetch_user, :only => [:show, :index]
  before_filter :fetch_article, :only => [:show, :edit]
  before_filter :find_article, :only => [:update, :destroy]
  before_filter :article_owner, :only => [:edit, :update, :destroy]  
 

  
  def index
    @articles = Article.blogger_articles(params[:user_id]).page params[:page]
    @cache_key = index_cache_key
  end

  def new
    @article = Article.new
  end

  def create
    @article = current_user.articles.build params[:article]
    @article.tag_list = params[:tags]

    if @article.save
      flash[:notice] = 'The article has been created'
      redirect_to user_article_path(current_user, @article)
    else
      flash[:alert] = 'The article has not been created'
      render :action => 'new'
    end
  end
  
  def show
    @comments = @article.threaded_comments.page params[:page]
    @comments_key = "#{Comment::base_key_for('Article', params[:id])}-page-#{params[:page] || 1}"
  end

  def edit
  end

  def update
    @article.tag_list = params[:tags] if params[:tags]
    if @article.update_attributes(params[:article])
      flash[:notice] = 'The article has been updated'
      redirect_to user_article_path(current_user, @article)
    else
      flash[:alert] = 'The article has not been updated'
      render :action => 'edit'
    end
  end

  def destroy
    @article.destroy
    flash[:notice] = 'The article has been deleted'
    redirect_to user_articles_path(current_user)
  end

  
  def search
    @articles = Article.default_list.page params[:page]
    @tag_counts = Article.tag_counts
    @key = search_cache_key
  end

  def search_by_tag
    tag = CGI.unescape params[:tag]
    @articles = Article.search_by_tag(tag).page params[:page]
    @tag_counts = Article.tag_counts
    @key = search_cache_key
    render 'articles/search'
  end

  def search_by_query
    if not ['content', 'tags'].include? params[:mode]
      redirect_to root_path
      return
    end

    @articles = Article.search_by_query params[:query] if params[:mode] == 'content'
    @articles = Article.search_by_tag params[:query] if params[:mode] == 'tags'
    @articles = @articles.in_blogs_selected_by current_user if params[:selected_blogs] && user_signed_in?
    @articles = @articles.page params[:page]
    
    @tag_counts = Article.tag_counts
    @key = search_cache_key
    respond_to do |format|
     format.html { render 'articles/search' } 
     format.js { render 'articles/search.js' }
    end
  end

private
  def find_article
    @article = Article.find params[:id]

    if @article.nil?
      flash[:alert] = 'The article was not found'
      redirect_to root_path
    end
  end

  def fetch_user
    @user = User.fetch params[:user_id]

    if @user.nil?
      flash[:alert] = 'The user was not found'
      redirect_to root_path
    end
  end

  def fetch_article
    @article = Article.fetch params[:id]

    if @article.nil?
      flash[:alert] = 'The article was not found'
      redirect_to root_path
    end
  end

  def article_owner
    if @article.user != current_user
      redirect_to user_articles_path(current_user)
    end
  end

  def index_cache_key
    "user-articles-#{@user.id}-#{Article.user_articles_base_key(@user.id)}-#{params[:page]}"
  end

  def search_cache_key
    "search-articles-#{Article.articles_base_key}-#{params[:page]}-#{params[:query]}-#{params[:mode]}-#{params[:tag]}-#{user_signed_in?}-#{params[:selected_blogs]}"
  end
end
