# joint table for Users and Events
class Participation < ApplicationRecord
  belongs_to :event
  belongs_to :user
end
