# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @events = Event.order(:Date)
    @msg = cookies[:msg]
    @logged_in = User.logged_in?(cookies.signed[:user_id])
    @officer = User.officer?(cookies.signed[:user_id])
    @view_all = cookies.signed[:view_all]
    @user = @logged_in ? User.find(cookies.signed[:user_id]) : { id: nil }
  end

  def show
    @event = Event.find(params[:id])
  end

  def switch_view
    @view_all = cookies.signed[:view_all]
    @view_all = !@view_all
    cookies.signed[:view_all] = @view_all
    redirect_to(events_path)
  end

  def new
    unless User.officer?(cookies.signed[:user_id])
      cookies[:msg] = 'Must be Administrator to create events'
      redirect_to(events_path)
      return
    end
    @event = Event.new
  end

  def create
    if params[:event][:Name].blank?
      @msg = 'Name cannot be empty'
      @event = Event.new(event_params)
      render('new')
      return
    end
    params[:event] = default_params(params[:event])

    @event = Event.create(event_params)
    if @event.save
      redirect_to(events_path)
    else
      render('new')
    end
  end

  def attend
    unless User.logged_in?(cookies.signed[:user_id])
      cookies[:msg] = 'Must be logged in to sign up for events.'
      redirect_to(events_path)
      return
    end
    event = Event.find(params[:id])
    unless event[:Date].nil? || event[:Date] > 1.day.since
      cookies[:msg] = 'Cannot sign up for event happening within 24 hours.'
      redirect_to(events_path)
      return
    end
    user = User.find(cookies.signed[:user_id])

    try_adding_user_to_event(event, user)
  end

  def unattend
    if User.logged_in?(cookies.signed[:user_id])
      event = Event.find(params[:id])
      user = User.find(cookies.signed[:user_id])

      if user.events.delete(event) && event.users.delete(user)
        cookies[:msg] = "You are no longer registered for the event: #{event.Name}"
      end
    else
      cookies[:msg] = 'Must be logged in to unattend events.'
    end

    redirect_to(events_path)
  end

  def edit
    unless User.officer?(cookies.signed[:user_id])
      cookies[:msg] = 'Must be Administrator to edit events'
      redirect_to(events_path)
      return
    end
    @event = Event.find(params[:id])
  end

  def update
    if params[:event][:Name].blank?
      @msg = 'Name cannot be empty'
      @event = Event.new(event_params)
      render('edit')
      return
    end
    params[:event] = default_params(params[:event])

    @event = Event.find(params[:id])
    if @event.update(event_params)
      redirect_to(event_path(@event))
    else
      render('edit')
    end
  end

  def delete
    unless User.officer?(cookies.signed[:user_id])
      cookies[:msg] = 'Must be Administrator to delete events'
      redirect_to(events_path)
      return
    end
    @event = Event.find(params[:id])
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    redirect_to(events_path)
  end

  private

  def try_adding_user_to_event(event, user)
    if event.users.include? user
      cookies[:msg] = "You are already signed up for the event: #{event.Name}"
    else
      event.users << user # this will create a joint tabl entry and also add the event to "user.events"
      cookies[:msg] = "You are now signed up for the event: #{event.Name}"
    end
    redirect_to(events_path)
  end

  def event_params
    params.require(:event).permit(:Name, :Date, :Location, :Points, :PointType, :Description)
  end

  def default_params(event)
    if event[:Date].blank?
      event[:Date] = Time.zone.now
    end
    if event[:Points].blank?
      event[:Points] = 0
    end
    if event[:PointType].blank?
      event[:PointType] = "Other"
    end
    event
  end
end
