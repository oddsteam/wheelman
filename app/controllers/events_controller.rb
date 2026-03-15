class EventsController < ApplicationController
  def new
    @event = Event.new
  end
  def create
    Event.create(event_params) 
  end
  private
  def event_params
    params.expect(event: [ :name ])
  end
end
