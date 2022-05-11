describe 'Creating an Event', type: :feature do
  scenario 'Admin clicks create button' do
    allow(User).to receive(:officer?).and_return(true)

    visit events_url
    click_on 'Create Event'
    expect(page).to have_current_path('/events/new')
    fill_in 'event_Name', with: 'Example Event'
    click_on 'Create Event'
    expect(page).to have_current_path('/events')
    expect(page).to have_content('Example Event')
  end

  scenario 'Normal user visits create event url directly' do
    visit '/events/new'
    expect(page).to have_current_path('/events')
  end

  after(:all) do
    User.delete_all
    Event.delete_all
  end
end
