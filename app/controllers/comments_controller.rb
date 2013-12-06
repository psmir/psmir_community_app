require 'my_exceptions'

class CommentsController < ApplicationController
  include MyExceptions

  before_filter :authenticate_user!
  before_filter :find_resource

  def new
    @comment = Comment.new
  end

  def create
    unless params[:comment]
      @comment = Comment.new
      render :new
      return
    end

    @comment = Comment.build_from(@resource, current_user.id, params[:comment][:body])

    begin
      @comment.attach_to_comment_with_id params[:parent] if params[:parent]
    rescue ParentCommentNotFound => e
      flash[:alert] = e.message
      redirect_to @resource
      return
    end

    if @comment.save
      flash[:notice] = 'The comment has been created'
      redirect_to @resource
    else
      flash[:alert] = 'The comment has not been created'
      render :action => 'new'
    end
  end

  private

  def find_resource
    @resource = Article.find(params[:article_id])
  end
end
