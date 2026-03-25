class EventsController < ApplicationController
  def index
    @events = Event.order(start_date: :asc)
    @events_by_category = @events.group_by(&:category)

  end

  def me
    @events = Event.order(start_date: :asc)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to events_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def event_params
    puts params
    params.expect(event: [ :photo, :name, { activity_type: [] }, :category, :description, :location_description, :location_link, :start_date, :end_date ])
  end
end
