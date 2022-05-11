# frozen_string_literal: true

##
# Handles the user table
class UsersController < ApplicationController
  def login
    cookies[:msg] = sign_in_with_google
    if cookies[:msg] == 'Need more information'
      redirect_to form_url
    else
      redirect_to :root
    end
  end

  def logout
    cookies.signed[:user_id] = nil
    cookies[:msg] = ''
    redirect_to :root
  end

  def form
    @user = User.find(cookies.signed[:user_id])
  end

  def validate_form
    params.require(:user).permit(:uin, :phone)
    user = params[:user]

    # validate inputs with regex
    valid_phone = user[:phone].match?('^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$')
    valid_uin = user[:uin].match?('[0-9]{3}(0){2}[0-9]{4}')

    if valid_phone && valid_uin
      update_user_info(user[:uin], user[:phone])
    else
      redirect_to form_url
    end
  end

  def index
    redirect_to(events_path) unless User.officer?(cookies.signed[:user_id])

    @users = User.order(:uin)
  end

  def show
    if User.officer?(cookies.signed[:user_id]) || (cookies.signed[:user_id] == params[:id])
      @user = User.find(params[:id])
      @points = Point.where(uin: @user.uin).order(:point_type)
    else
      redirect_to(events_path)
    end
  end

  def edit
    redirect_to(events_path) unless User.officer?(cookies.signed[:user_id]) || (cookies.signed[:user_id] == params[:id])

    @user = User.find(params[:id])
    @officer = User.officer?(cookies.signed[:user_id])
  end

  def update
    unless User.officer?(cookies.signed[:user_id]) || (cookies.signed[:user_id] == params[:id])
      redirect_to(events_path)
      return
    end

    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to(users_url)
    else
      render('edit')
    end
  end

  def delete
    redirect_to(events_path) unless User.officer?(cookies.signed[:user_id])

    @user = User.find(params[:id])
  end

  def destroy
    if User.officer?(cookies.signed[:user_id])
      @user = User.find(params[:id])
      @user.destroy
    end

    redirect_to(users_path)
  end

  private

  ##
  # Replaces the current user's uin and phone fields with the given parameters,
  # updates the message cookie, then redirects to the home page.
  #
  # The current user's id is assumed to be stored at <tt>cookies.signed[:user_id]<tt>
  #
  # @param uin - string to replace the currently stored uin
  # @param phone - string to replace the currently stored phone number
  def update_user_info(uin, phone)
    user = User.find(cookies.signed[:user_id])
    user.update({ uin: uin, phone: phone })
    cookies[:msg] = "#{user[:first_name]} #{user[:last_name]} logged in as #{user[:email]}"
    redirect_to(:root)
  end

  ##
  # Parses Google's OAuth response.
  #
  # If authentication is successful the user's id_token is stored in <tt> cookie.signed[:user_id] </tt>
  #
  # @return a message that shows how authentication went
  def sign_in_with_google
    google_response = flash&.[](:google_sign_in)
    return 'Could not find Google\'s response' if google_response.nil?

    if (id_token = google_response&.[]('id_token'))
      user = parse_google_identity(id_token)
      login_user(user)
    elsif (error = google_response&.[]('error'))
      "Google Authentication Error: #{error}"
    else
      'Couldn\'t process Google\'s response'
    end
  end

  ##
  # Constructs a dictionary detailing user info based off the provided <tt> id_token </tt>
  #
  # @param id_token - retrieved from flash[:google_sign_in]['id_token']
  #
  # @return a dictionary containing google_id, email, first_name, and last_name.
  def parse_google_identity(id_token)
    identity = GoogleSignIn::Identity.new(id_token)
    {
      google_id: identity.user_id,
      email: identity.email_address,
      first_name: identity.given_name,
      last_name: identity.family_name
    }
  end

  ##
  # Logs in the user and adds this user to the database if it doesn't already exist
  #
  # @param user - a dictionary containing google_id, email, first_name, and last_name fields.
  #
  # @return string indicating full or partial login status
  def login_user(user)
    id = User.id_from_google_id(user[:google_id])

    User.create!(user) if id.nil?

    cookies.signed[:user_id] = { value: User.id_from_google_id(user[:google_id]), expires: Time.now + 3600 }

    if User.logged_in?(id)
      "Howdy #{user[:first_name]}! You're logged in as \"#{user[:email]}\"."
    else
      'Need more information'
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :uin, :phone, :email, :meeting_points, :event_points,
                                 :social_points, :other_points, :officer, :google_id)
  end
end
