class Room < ApplicationRecord
  has_many :participants
  has_many :messages
end
