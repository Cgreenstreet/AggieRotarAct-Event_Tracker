RSpec.describe EventsController, type: :controller do
  before(:all) do
    Event.create(id: 1, Name: 'Example Event')
  end

  after(:all) do
    Event.delete_all
  end

  describe '#index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end

    it 'shows all events' do
      events = double('order')
      allow(Event).to receive(:order).and_return(events)

      get :index
      expect(assigns[:events]).to eq(events)
    end
  end

  describe '#show' do
    it 'renders the show template' do
      get :show, params: { id: 1 }
      expect(response).to render_template('show')
    end

    it 'shows details about one event' do
      event = double('find')
      allow(Event).to receive(:find).and_return(event)

      get :show, params: { id: 1 }
      expect(assigns[:event]).to eq(event)
    end
  end

  describe '#new' do
    it 'makes a new event' do
      event = double('new')
      allow(Event).to receive(:new).and_return(event)
      allow(User).to receive(:officer?).and_return(true)

      get :new
      expect(assigns[:event]).to eq(event)
    end

    it 'only allows admins' do
      allow(Event).to receive(:new).and_raise('normal user made event')

      expect { get :new }.to_not raise_error
    end
  end

  describe '#create' do
    params = {
      event: {
        Name: 'New Event',
        Date: 'January 1, 2000',
        Location: 'MSC',
        Points: 3
      }
    }

    it 'makes a new event' do
      event = double('create')
      allow(event).to receive(:save).and_return(true)
      allow(Event).to receive(:create).and_return(event)

      get :create, params: params
      expect(assigns[:event]).to eq(event)
      expect(response).to redirect_to(events_url)
    end

    it 'redirects to #new if creation fails' do
      event = double('create')
      allow(event).to receive(:save).and_return(false)
      allow(Event).to receive(:create).and_return(event)

      get :create, params: params
      expect(response).to render_template('new')
    end
  end

  describe '#edit' do
    it 'renders the edit page' do
      allow(User).to receive(:officer?).and_return(true)

      get :edit, params: { id: 1 }
      expect(response).to render_template('edit')
    end

    it 'shows the fields of one event' do
      allow(User).to receive(:officer?).and_return(true)
      event = double('find')
      allow(Event).to receive(:find).and_return(event)

      get :edit, params: { id: 1 }
      expect(assigns[:event]).to eq(event)
    end

    it 'only allows admins' do
      allow(Event).to receive(:find).and_raise('normal user edited event')

      expect { get :edit, params: { id: 1 } }.to_not raise_error
      expect(response).to redirect_to(events_url)
    end
  end

  describe '#update' do
    it 'renders the edit page if update fails' do
      event = double
      allow(event).to receive(:update).and_return(false)
      allow(Event).to receive(:find).and_return(event)
      get :update, params: { id: 1, event: { Name: 'Blah' } }
      expect(response).to render_template('edit')
    end
  end

  describe '#delete' do
    it 'renders the delete page' do
      allow(User).to receive(:officer?).and_return(true)

      get :delete, params: { id: 1 }
      expect(response).to render_template('delete')
    end

    it 'shows which event you\'ll delete' do
      allow(User).to receive(:officer?).and_return(true)
      event = double('find')
      allow(Event).to receive(:find).and_return(event)

      get :delete, params: { id: 1 }
      expect(assigns[:event]).to eq(event)
    end

    it 'only allows admins' do
      allow(Event).to receive(:find).and_raise('normal user deleted event')

      expect { get :delete, params: { id: 1 } }.to_not raise_error
    end
  end

  describe '#attend' do
    before(:each) do
      User.create(google_id: 'member', email: 'member@example.com', first_name: 'John', last_name: 'Doe')
    end

    after(:each) do
      User.destroy(User.id_from_google_id('member'))
    end

    it 'lets a user attend an event' do
      allow(User).to receive(:logged_in?).and_return(true)
      allow(User).to receive(:find).and_return(User.find(User.id_from_google_id('member')))
      post :attend, params: { id: 1 }
      expect(response).to redirect_to(events_url)
      expect(Event.find(1).users.count).to eq(1)
      expect(User.find(User.id_from_google_id('member')).events.count).to eq(1)

      # but not re-attend
      post :attend, params: { id: 1 }
      expect(response).to redirect_to(events_url)
      expect(Event.find(1).users.count).to eq(1)
      expect(User.find(User.id_from_google_id('member')).events.count).to eq(1)
    end

    it 'only works if the user is logged in' do
      post :attend, params: { id: 1 }
      expect(response).to redirect_to(events_url)
      expect(Event.find(1).users.count).to eq(0)
    end
  end

  describe '#unattend' do
    before(:each) do
      User.create(google_id: 'member', email: 'member@example.com', first_name: 'John', last_name: 'Doe')
    end

    after(:each) do
      User.destroy(User.id_from_google_id('member'))
    end

    it 'lets a user unattend an event' do
      allow(User).to receive(:logged_in?).and_return(true)
      allow(User).to receive(:find).and_return(User.find(User.id_from_google_id('member')))
      post :attend, params: { id: 1 }
      expect(response).to redirect_to(events_url)
      expect(Event.find(1).users.count).to eq(1)

      post :unattend, params: { id: 1 }
      expect(response).to redirect_to(events_url)
      expect(Event.find(1).users.count).to eq(0)
    end

    it 'only works for logged in users' do
      allow(Event).to receive(:find).and_raise('bypassed login check')
      expect { post :unattend, params: { id: 1 } }.to_not raise_error
    end
  end
end
