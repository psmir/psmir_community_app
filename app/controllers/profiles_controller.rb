class ProfilesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :avatar]
  before_filter :fetch_profile, :only => [:show, :edit, :avatar]
  before_filter :find_profile, :only => [:update]
  before_filter :check_owner, :only => [:edit, :update]


  def show
    @favorite_bloggers = @profile.user.bloggers.page params[:page]
  end

  def edit
  end

  def update
    if @profile.update_attributes params[:profile]
      flash[:notice] = 'The profile has been updated'
      redirect_to profile_path(@profile)
    else
      flash[:alert] = 'The profile has not been updated'
      render :action => 'edit'
    end
    
  end

  def avatar
    @avatar = @profile.get_avatar_file params[:style]
    send_data(@avatar, :type => @profile.avatar_content_type, :disposition => 'inline')
  end

private
  def fetch_profile
    @profile = Profile.fetch params[:id]

    if @profile.nil? 
      flash[:alert] = 'The profile was not found'
      redirect_to root_path
      return
    end
  end

  def find_profile
    @profile = Profile.find params[:id]

    if @profile.nil? 
      flash[:alert] = 'The profile was not found'
      redirect_to root_path
      return
    end
  end

  def check_owner
    if @profile.user != current_user
      flash[:alert] = 'You are not allowed to do so'
      redirect_to root_path
    end
  end
  
end
