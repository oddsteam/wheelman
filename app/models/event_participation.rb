class EventParticipation < ApplicationRecord
  belongs_to :user
  belongs_to :event

  # a user can join a given event only once
  validates :user_id, uniqueness: { scope: :event_id }
end
