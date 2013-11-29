require 'my_exceptions'

class CommentsController < ApplicationController
  include MyExceptions

  before_filter :authenticate_user!
  before_filter :fetch_article

  def new
    @comment = Comment.new
  end

  def create
    if params[:comment].nil?
      redirect_to new_article_comment_path(@article)
      return
    end

    @comment = Comment.build_from(@article, current_user.id, params[:comment][:body])
    begin
      @comment.attach_to_comment_with_id params[:parent] if params[:parent]
    rescue ParentCommentNotFound => e
      flash[:alert] = e.message
      redirect_to article_path(@article)
      return
    end

    if @comment.save
      flash[:notice] = 'The comment has been created'
      redirect_to article_path(@article)
    else
      flash[:alert] = 'The comment has not been created'
      render :action => 'new'
    end
  end

 private

  def fetch_article
    @article = Article.find(params[:article_id])

    if @article.nil?
      flash[:alert] = 'The article was not found'
      redirect_to root_path
    end
  end
end
