describe 'Edit User', type: :feature do
  before(:all) do
    User.create(google_id: 'member', email: 'member@example.com', first_name: 'John', last_name: 'Doe')
    @user_id = User.id_from_google_id('member')
  end

  before(:each) do
    allow(User).to receive(:logged_in?).and_return(true)
    allow(User).to receive(:find).and_return(User.find(@user_id))
  end

  scenario 'Admin clicks on edit user button' do
    allow(User).to receive(:officer?).and_return(true)
    visit users_url
    click_on 'Edit'
    expect(page).to have_current_path("/users/#{@user_id}/edit")
  end

  scenario 'Non-admin visits edit url' do
    allow(User).to receive(:logged_in?).and_return(true)
    visit "/users/#{@user_id}/edit"
    expect(page).to have_current_path(events_url)
  end

  after(:all) do
    User.delete_all
  end
end
