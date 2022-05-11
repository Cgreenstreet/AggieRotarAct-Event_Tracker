RSpec.describe PointsController, type: :controller do
  before(:all) do
    User.create(google_id: 'officer', email: 'officer@example.com', first_name: 'Jane', last_name: 'Doe',
                officer: true, uin: '123004567', phone: '555-555-5555')
    @user = User.find(User.id_from_google_id('officer'))
  end

  describe '#index' do
    it 'makes a new point object' do
      allow(User).to receive(:officer?).and_return(true)
      point = double
      allow(Point).to receive(:new).and_return(point)
      get :index
      expect(assigns[:point]).to eq(point)
    end

    it 'only allows admins' do
      get :index
      expect(response).to redirect_to(events_url)
    end
  end

  describe '#create' do
    it 'submits the form' do
      params = { point: { name: 'Event', number: 1, point_type: 'Meeting', uin: @user[:uin] } }
      old_count = Point.count
      post :create, params: params
      expect(Point.count).to eq(old_count + 1)

      params = { point: { name: 'Event', number: 1, point_type: 'Event', uin: @user[:uin] } }
      old_count = Point.count
      post :create, params: params
      expect(Point.count).to eq(old_count + 1)

      params = { point: { name: 'Event', number: 1, point_type: 'Social', uin: @user[:uin] } }
      old_count = Point.count
      post :create, params: params
      expect(Point.count).to eq(old_count + 1)

      params = { point: { name: 'Event', number: 1, point_type: 'Other', uin: @user[:uin] } }
      old_count = Point.count
      post :create, params: params
      expect(Point.count).to eq(old_count + 1)
    end

    it 'makes sure all field are filled out' do
      params = { point: { uin: @user[:uin] } }
      old_count = Point.count
      post :create, params: params
      expect(Point.count).to eq(old_count)
    end

    it 'only works if the UIN is in the database' do
      params = { point: { name: 'Event', number: 1, point_type: 'Social', uin: '999999' } }
      old_count = Point.count
      post :create, params: params
      expect(Point.count).to eq(old_count)
    end
  end

  describe '#delete' do
    before(:all) do
      Point.new(name: 'Example Event', number: 10, point_type: 'Other', uin: @user[:uin]).save(validate: false)
      point = Point.where(name: 'Example Event')
      @point_id = point.select(:id).take[:id]
    end

    after(:all) do
      Point.delete_all
    end

    it 'renders the delete page' do
      allow(User).to receive(:officer?).and_return(true)
      get :delete, params: { id: @point_id }
      expect(response).to render_template('delete')
    end

    it 'only allow admins' do
      get :delete, params: { id: @point_id }
      expect(response).to_not render_template('delete')
    end
  end

  describe '#destroy' do
    before(:each) do
      Point.new(name: 'Example Event', number: 10, point_type: 'Other', uin: @user[:uin]).save(validate: false)
      point = Point.where(name: 'Example Event')
      @point_id = point.select(:id).take[:id]
    end

    after(:each) do
      Point.delete_all
    end

    it 'removes a point object from the database' do
      old_count = Point.count
      get :destroy, params: { id: @point_id }
      expect(response).to redirect_to(users_url)
      expect(Point.count).to eq(old_count - 1)
    end
  end
end
