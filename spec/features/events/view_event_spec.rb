describe 'Viewing an Event', type: :feature do
  before(:all) do
    Event.new(id: 1, Name: 'Example Event', Date: Date.new(2021, 1, 1)).save
  end

  scenario 'Anyone clicks on an event' do
    visit events_url
    click_on 'Example Event'
    expect(page).to have_current_path('/events/1')
    expect(page).to have_content('Example Event')
  end

  after(:all) do
    Event.delete_all
  end
end
