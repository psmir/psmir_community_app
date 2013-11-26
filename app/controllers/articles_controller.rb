require 'cgi'
class ArticlesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :search, :search_by_tag, :search_by_query]
  before_filter :find_user, :only => [:show, :index]
  before_filter :find_article, :only => [:show, :edit, :update, :destroy]
  before_filter :article_owner, :only => [:edit, :update, :destroy]



  def index
    @articles = articles.default_list.page(params[:page])
    @articles = @articles.tagged_with(unescaped_tag) if params[:tag]
    @articles = @articles.tagged_with(params[:query]) if params[:query] && params[:mode] == 'tags'
    @articles = @articles.with_query(params[:query]) if params[:query] && params[:mode] == 'content'
    @articles = @articles.in_selected_blogs(current_user) if params[:selected_blogs] && current_user
    @tag_counts = Article.tag_counts
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
    @comments = @article.threaded_comments.page(params[:page])
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
  end

  def search_by_tag
    tag = CGI.unescape params[:tag]
    @articles = Article.search_by_tag(tag).page params[:page]
    @tag_counts = Article.tag_counts
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

    respond_to do |format|
     format.html { render 'articles/search' }
     format.js { render 'articles/search.js' }
    end
  end

  private

  def find_article
    @article = Article.find(params[:id])
  end

  def find_user
    @user = User.find_by_id(params[:user_id])
  end

  def articles
    @user ? @user.articles : Article.scoped
  end

  def article_owner
    if @article.user != current_user
      redirect_to user_articles_path(current_user)
    end
  end

  def unescaped_tag
    CGI.unescape params[:tag]
  end
end
