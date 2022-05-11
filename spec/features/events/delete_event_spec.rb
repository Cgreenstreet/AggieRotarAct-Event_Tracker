describe 'Deleting an Event', type: :feature do
  before(:each) do
    Event.new(id: 1, Name: 'Example Event', Date: Date.new(2021, 1, 1)).save
  end

  after(:each) do
    Event.delete_all
  end

  scenario 'admin clicks on delete button' do
    allow(User).to receive(:officer?).and_return(true)

    visit events_url
    click_on 'Delete'
    expect(page).to have_current_path('/events/1/delete')
    click_on 'Delete Event'
    expect(page).to have_current_path('/events')
    expect(Event.count).to eq(0)
  end

  scenario 'normal user visits deletion url directly' do
    visit '/events/1/delete'
    expect(page).to have_current_path('/events')
  end
end
