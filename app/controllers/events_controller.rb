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
    puts params 
    params.expect(event: [ :photo, :name, { activity_type: [] }, :category, :description, :location_description, :location_link, :start_date, :end_date])
  end
end
