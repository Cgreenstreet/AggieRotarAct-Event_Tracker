describe 'Delete User', type: :feature do
  before(:each) do
    User.create(google_id: 'member', email: 'member@example.com', first_name: 'John', last_name: 'Doe')
    @user_id = User.id_from_google_id('member')
    allow(User).to receive(:find).and_return(User.find(@user_id))
    allow(User).to receive(:logged_in?).and_return(true)
  end

  after(:each) do
    User.delete_all
  end

  scenario 'Admin clicks on delete user button' do
    allow(User).to receive(:officer?).and_return(true)
    visit users_url
    click_on 'Delete'
    expect(page).to have_current_path("/users/#{@user_id}/delete")
    click_on 'Remove User'
    expect(page).to have_current_path('/users')
    expect(User.count).to eq(0)
  end

  scenario 'Non-admin visits delete user url' do
    visit "/users/#{@user_id}/delete"
    expect(page).to have_current_path(events_url)
  end
end
