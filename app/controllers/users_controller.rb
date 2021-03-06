class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_blogger

  def follow
    current_user.follow @blogger
    redirect_to user_articles_path(@blogger)
  end

  def unfollow
    current_user.unfollow @blogger
    redirect_to user_articles_path(@blogger)
  end

  def find_blogger
    @blogger = User.find(params[:id])
  end
end
