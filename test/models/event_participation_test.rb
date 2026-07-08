require "test_helper"

class EventParticipationTest < ActiveSupport::TestCase
  test "a user can join an event only once" do
    user = users(:one)
    event = events(:one)

    assert EventParticipation.create(user: user, event: event).persisted?
    dup = EventParticipation.new(user: user, event: event)
    assert_not dup.valid?
  end

  test "different users can join the same event" do
    event = events(:one)
    assert EventParticipation.create(user: users(:one), event: event).persisted?
    assert EventParticipation.create(user: users(:two), event: event).persisted?
  end
end
