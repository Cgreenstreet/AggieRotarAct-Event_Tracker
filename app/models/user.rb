# frozen_string_literal: true

class User < ApplicationRecord
  # has_many :points
  has_many :participations, dependent: :delete_all
  has_many :events, through: :participations, dependent: :delete_all
  # These fields should be present when first creating the user. You can get them through Google OAuth
  validates :google_id, uniqueness: true, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, uniqueness: true, presence: true

  # Fields added in via a form at first sign in
  # uin - University Identification Number (string)
  # phone - phone number (string)

  # Assume a new user is not an officer
  attribute :officer, :boolean, default: false
  # initialize user with 0 points
  attribute :points, :integer, default: 0

  ##
  # Gets the database id of the user with a Google ID equal to <tt>google_id</tt>
  #
  # Returns the id of the user with <tt>google_id</tt> or nil if no such user exists.
  def self.id_from_google_id(google_id)
    return nil unless User.exists?(google_id: google_id)

    user = User.where(google_id: google_id)
    user.select(:id).take[:id]
  end

  ##
  # Checks if the user with the given <tt>id</tt> is an officer.
  #
  # <tt>id</tt> should come from a cookie (probably <tt>cookies.signed[:user_id]</tt>)
  # to see if the currently active user is an officer.
  #
  # Returns true if the user is an officer, false otherwise.
  def self.officer?(id)
    if User.exists?(id)
      User.find(id)[:officer]
    else
      false
    end
  end

  ##
  # Checks if a user with the given <tt>id</tt> is in the database and has all fields filled out.
  #
  # <tt>id</tt> should come from a cookie (probably <tt>cookies.signed[:user_id]</tt>)
  # to see if the currently active user is logged in.
  #
  # Returns true if <tt>id</tt> corresponds to a user with all fields filled out, false otherwise.
  def self.logged_in?(id)
    if User.exists?(id)
      user = User.find(id)
      !user[:phone].nil? && !user[:uin].nil?
    else
      false
    end
  end
end
