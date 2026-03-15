class EventsController < ApplicationController
  def index
  end

  def new
    @event = Event.new
  end

  def create
    Event.create(event_params)
    redirect_to events_path
  end

  private

  def event_params
    params.expect(event: [ :name, :description, :location_description, :location_link ])
  end
end
