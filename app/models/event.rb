# frozen_string_literal: true

class Event < ApplicationRecord
  has_many :points
  has_many :participations
  has_many :users, through: :participations, dependent: :delete_all
end
