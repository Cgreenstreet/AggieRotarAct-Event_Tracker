RSpec.describe UsersController, type: :controller do
  before(:all) do
    @member = User.new(google_id: 'member', email: 'member@example.com', first_name: 'John', last_name: 'Doe')
    @officer = User.new(google_id: 'officer', email: 'officer@example.com', first_name: 'Jane', last_name: 'Doe',
                        officer: true, uin: '123004567', phone: '555-555-5555')

    @member.save
    @officer.save
  end

  describe 'login' do
    it 'logs a user in' do
      allow(GoogleSignIn::Identity).to receive(:new).with('officer').and_return(MockIdentity.new(@officer))
      flash = { google_sign_in: { 'id_token' => 'officer' } }
      get :login, flash: flash
      expect(response).to redirect_to(:root)
    end

    it 'asks for more information' do
      allow(GoogleSignIn::Identity).to receive(:new).with('member').and_return(MockIdentity.new(@member))
      flash = { google_sign_in: { 'id_token' => 'member' } }
      get :login, flash: flash
      expect(response).to redirect_to(:form)
    end

    it 'shows the authentication error' do
      flash = { google_sign_in: { 'error' => 'some error' } }
      get :login, flash: flash
      expect(response).to redirect_to(:root)
    end

    it 'shows that a process couldn\'t be parsed' do
      get :login, flash: { google_sign_in: 'blah' }
      expect(response).to redirect_to(:root)
    end
  end

  describe 'logout' do
    it 'logs the user out' do
      get :logout
      expect(response).to redirect_to(:root)
    end
  end

  describe 'form' do
    it 'shows the form page for a given user' do
      user = double('find')
      allow(User).to receive(:find).and_return(user)
      get :form
      expect(assigns[:user]).to eq(user)
      expect(response).to render_template('form')
    end
  end

  describe 'validate_form' do
    it 'checks to see if parameters are there' do
      expect { post :validate_form }.to raise_error(ActionController::ParameterMissing)
    end

    it 'makes sure the phone number is valid' do
      post :validate_form, params: { user: { uin: '123004567', phone: '5743jfwj90812' } }
      expect(response).to redirect_to(:form)
    end

    it 'makes sure the uin is valid' do
      post :validate_form, params: { user: { uin: '999999999', phone: '555-555-5555' } }
      expect(response).to redirect_to(:form)
    end

    it 'updates the user\'s information' do
      user = double('find')
      allow(user).to receive(:update).and_raise('Updated successfully')
      allow(User).to receive(:find).and_return(user)
      expect { post :validate_form, params: { user: { uin: '999009999', phone: '555-555-5555' } } }
        .to raise_error('Updated successfully')
    end

    it 'returns to the home page on successful update' do
      allow(User).to receive(:find).and_return(@member)
      post :validate_form, params: { user: { uin: '999009999', phone: '555-555-5555' } }
      expect(response).to redirect_to(:root)
    end
  end

  describe 'edit' do
    it 'allows officers to edit any user' do
      allow(User).to receive(:officer?).and_return(true)
      get :edit, params: { id: User.id_from_google_id('member') }
      expect(response).to render_template('edit')
    end

    it 'does not allow normal users to edit another user' do
      get :edit, params: { id: User.id_from_google_id('member') }
      expect(response).to redirect_to(events_url)
    end

    it 'allows a user to edit their own information' do
      cookies.signed[:user_id] = User.id_from_google_id('member')
      get :edit, params: { id: User.id_from_google_id('member') }
      expect(response).to render_template('edit')
    end
  end

  describe 'index' do
    it 'renders the user dashboard' do
      allow(User).to receive(:officer?).and_return(true)
      get :index
      expect(response).to render_template('index')
    end

    it 'only works for admins' do
      get :index
      expect(response).to redirect_to(events_url)
    end
  end

  describe 'show' do
    it 'shows information about a specific user' do
      allow(User).to receive(:officer?).and_return(true)
      get :show, params: { id: @member[:id] }
      expect(response).to render_template('show')
    end

    it 'only works for admins' do
      get :show, params: { id: @member[:id] }
      expect(response).to redirect_to(events_path)
    end
  end

  describe 'update' do
    it 'updates a user\'s information' do
      allow(User).to receive(:officer?).and_return(true)
      params = { id: @member[:id], user: { first_name: 'Bob' } }
      get :update, params: params
      expect(response).to redirect_to(users_url)
    end

    it 'only works for admins' do
      params = { id: @member[:id], user: { first_name: 'Bob' } }
      get :update, params: params
      expect(response).to redirect_to(events_url)
    end

    it 'renders the edit page if update fails' do
      user = double
      allow(user).to receive(:update).and_return(false)
      allow(User).to receive(:officer?).and_return(true)
      allow(User).to receive(:find).and_return(user)
      params = { id: @member[:id], user: { first_name: 'Bob' } }
      get :update, params: params
      expect(response).to render_template('edit')
    end
  end

  describe 'delete' do
    it 'renders the delete user page' do
      allow(User).to receive(:officer?).and_return(true)
      get :delete, params: { id: @member[:id] }
    end
  end

  describe 'destroy' do
    it 'removes a user from the database' do
      user = double('find')
      allow(user).to receive(:destroy).and_raise('Destroyed successfully')
      allow(User).to receive(:officer?).and_return(true)
      allow(User).to receive(:find).and_return(user)
      expect { get :destroy, params: { id: @member[:id] } }.to raise_error('Destroyed successfully')
    end

    it 'only works for admins' do
      user = double('find')
      allow(user).to receive(:destroy).and_raise('Destroyed successfully')
      allow(User).to receive(:find).and_return(user)
      get :destroy, params: { id: @member[:id] }
      expect(response).to redirect_to(users_path)
    end
  end

  after(:all) do
    User.delete_all
  end
end

class MockIdentity
  def initialize(user)
    @user_id = user[:google_id]
    @email_address = user[:email]
    @given_name = user[:first_name]
    @family_name = user[:family_name]
  end

  attr_reader :user_id, :email_address, :given_name, :family_name
end
