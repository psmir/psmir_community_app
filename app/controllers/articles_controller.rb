require 'cgi'
class ArticlesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :find_user, :only => [:show, :index]
  before_filter :find_article, :only => [:show, :edit, :update, :destroy]

  authorize_resource :except => [:index, :show]



  def index
    @articles = articles.default_list.page(params[:page])
    @articles = @articles.tagged_with(unescaped_tag) if params[:tag]
    @articles = @articles.tagged_with(params[:query]) if params[:query] && params[:mode] == 'tags'
    @articles = @articles.with_query(params[:query]) if params[:query] && params[:mode] == 'content'
    @articles = @articles.in_blogs_selected_by(current_user) if params[:selected_blogs] && current_user
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
      redirect_to article_path(@article)
    else
      flash[:alert] = 'The article has not been created'
      render :action => 'new'
    end
  end

  def show
    @user = @article.user
    @comments = @article.threaded_comments.page(params[:page])
  end

  def edit
  end

  def update
    @article.tag_list = params[:tags] if params[:tags]

    if @article.update_attributes(params[:article])
      flash[:notice] = 'The article has been updated'
      redirect_to article_path(@article)
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

  def unescaped_tag
    CGI.unescape params[:tag]
  end
end
