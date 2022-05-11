describe 'Attending an Event', type: :feature do
  before(:all) do
    Event.create(id: 1, Name: 'Example Event', Date: Date.new(2022, 1, 1))
    User.create(google_id: 'member', email: 'member@example.com', first_name: 'John', last_name: 'Doe')
    @user = User.find(User.id_from_google_id('member'))
  end

  scenario 'Member attends event' do
    allow(User).to receive(:logged_in?).and_return(true)
    allow(User).to receive(:find).and_return(@user)

    visit events_url
    click_on 'View All Events'
    click_on 'Sign Up'
    click_on 'View My Events'
    expect(page).to have_current_path('/events')
    expect(page).to have_content('Signed Up Events')
    expect(page).to have_content('Example Event')
  end

  after(:all) do
    User.delete_all
    Event.delete_all
  end
end
