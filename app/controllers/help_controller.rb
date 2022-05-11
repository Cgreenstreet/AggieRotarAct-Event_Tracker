class HelpController < ApplicationController
  def index
    @logged_in = User.logged_in?(cookies.signed[:user_id])
    @officer = User.officer?(cookies.signed[:user_id])
  end

  def social_media
    #return if User.officer?(cookies.signed[:user_id])

    redirect_to(help_url)
  end

  def delete_events
    #return if User.officer?(cookies.signed[:user_id])

    redirect_to(help_url)
  end

  def destroy_events; end

  def delete_members
    #return if User.officer?(cookies.signed[:user_id])

    redirect_to(help_url)
  end

  def destroy_members; end
end
