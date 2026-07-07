class EventsController < ApplicationController
  before_action :set_event, only: %i[detail join leave destroy]
  before_action :require_view_details, only: %i[detail me]
  before_action :require_create, only: %i[new create]
  before_action :require_join, only: %i[join leave]
  before_action :require_owner_or_admin, only: :destroy

  def index
    @events = Event.order(start_date: :asc)
    @events_by_category = @events.group_by(&:category)

    @year = (params[:year].presence || Date.current.year).to_i
    year_events = Event.where(start_date: Date.new(@year, 1, 1)..Date.new(@year, 12, 31))
                       .order(:start_date)
    @events_by_month = year_events.group_by { |event| event.start_date.month }
  end

  def me
    @events = current_user.joined_events.order(start_date: :asc)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user

    if @event.save
      redirect_to events_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def detail
  end

  def join
    current_user.joined_events << @event unless current_user.joined?(@event)
    redirect_to event_path(@event), notice: "Joined #{@event.name}"
  end

  def leave
    current_user.event_participations.where(event: @event).destroy_all
    redirect_to event_path(@event), notice: "Left #{@event.name}"
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: "Event deleted"
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def require_view_details
    deny unless current_user.can_view_event_details?
  end

  def require_create
    deny unless current_user.can_create_events?
  end

  def require_join
    deny unless current_user.can_join_events?
  end

  def require_owner_or_admin
    deny unless current_user.admin? || @event.user_id == current_user.id
  end

  def deny
    redirect_to events_path, alert: "You don't have permission to do that."
  end

  def event_params
    params.expect(event: [ :photo, :name, { activity_type: [] }, :category, :description, :location_description, :location_link, :start_date, :end_date ])
  end
end
