describe 'Editing an Event', type: :feature do
  before(:all) do
    Event.new(id: 1, Name: 'Example Event', Date: Date.new(2021, 1, 1)).save
  end

  scenario 'Admin clicks edit button' do
    allow(User).to receive(:officer?).and_return(true)

    visit events_url
    click_on 'Edit'
    expect(page).to have_current_path('/events/1/edit')
    fill_in 'event_Name', with: 'Edited'
    click_on 'Edit Event'
    expect(page).to have_current_path('/events/1')
    expect(page).to have_content('Edited')
  end

  scenario 'Normal user visits edit url directly' do
    visit '/events/1/edit' # path of edit form
    expect(page).to have_current_path('/events')
  end

  after(:all) do
    Event.delete_all
  end
end
