describe 'View User Dashboard', type: :feature do
  before(:all) do
    User.create(google_id: 'member', email: 'member@example.com', first_name: 'John', last_name: 'Doe')
  end

  before(:each) do
    allow(User).to receive(:logged_in?).and_return(true)
    allow(User).to receive(:find).and_return(User.find(User.id_from_google_id('member')))
  end

  scenario 'Admin clicks User Dashboard button' do
    allow(User).to receive(:officer?).and_return(true)
    visit events_url
    click_on 'User Dashboard'
    expect(page).to have_current_path('/users')
    expect(page).to have_content('John Doe')
  end

  scenario 'Non-admin visits the User Dashboard' do
    visit users_url
    expect(page).to have_current_path(events_url)
  end

  after(:all) do
    User.delete_all
  end
end
