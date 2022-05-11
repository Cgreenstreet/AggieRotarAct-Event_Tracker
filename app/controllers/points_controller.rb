class PointsController < ApplicationController
  def index
    unless User.officer?(cookies.signed[:user_id])
      cookies[:msg] = 'Must be Administrator to access'
      redirect_to(events_path)
      return
    end
    @point = Point.new
    @users = User.order(:created_at)
  end

  def create
    params.require(:point)
    point = params[:point]
    if point_filled_in?(point)
      find_user(point[:name], point[:number], point[:point_type], point[:uin])
    else
      @msg = 'Fields cannot be empty'
      @point = Point.new(point_params)
      render('index')
    end
  end

  def new; end

  def show; end

  def edit; end

  def delete
    unless User.officer?(cookies.signed[:user_id])
      cookies[:msg] = 'Must be Administrator to delete events from User'
      redirect_to(events_path)
      return
    end
    @point = Point.find(params[:id])
  end

  def destroy
    point = Point.find(params[:id])
    user = User.find_by uin: point.uin
    type = point.point_type
    number = point.number
    increment_points(user, type, -number.to_f)

    point.destroy
    redirect_to(users_url)
  end

  private

  def find_user(name, number, type, uin)
    if User.exists?(uin: uin)
      update_user_info(name, number.to_f, type, uin)
    else
      @msg = 'User Not Found'
      @point = Point.new(point_params)
      render('index')
    end
  end

  def update_user_info(name, number, type, uin)
    user = User.find_by(uin: uin)
    increment_points(user, type, number)
    point = Point.new(name: name, number: number, point_type: type, uin: uin)
    @msg = 'Assigning points for: Event: ' + name + ', UIN: ' + uin + ' ' + (point.save(validate: false) ? 'Succeeded!' : 'Failed!')
    @point = Point.new(point_params)
    render('index')
  end

  def increment_points(user, type, amount)
    case type
    when 'Meeting'
      user.increment!(:meeting_points, amount)
    when 'Event'
      user.increment!(:event_points, amount)
    when 'Social'
      user.increment!(:social_points, amount)
    else
      user.increment!(:other_points, amount)
    end
  end

  def point_filled_in?(point)
    name = point[:name]
    num = point[:number]
    type = point[:point_type]
    uin = point[:uin]
    !(name.blank? || num.blank? || type.blank? || uin.blank?)
  end

  def point_params
    params.require(:point).permit(:name, :number, :point_type, :uin)
  end
end
