describe 'View User', type: :feature do
  before(:all) do
    User.create(google_id: 'member', email: 'member@example.com', first_name: 'John', last_name: 'Doe')
    @user_id = User.id_from_google_id('member')
  end

  before(:each) do
    allow(User).to receive(:logged_in?).and_return(true)
    allow(User).to receive(:find).and_return(User.find(@user_id))
  end

  scenario 'Admin clicks on user' do
    allow(User).to receive(:officer?).and_return(true)
    visit users_url
    click_on 'John Doe'
    expect(page).to have_current_path("/users/#{@user_id}")
    expect(page).to have_content('John Doe')
  end

  scenario 'Non-admin visits user url' do
    visit "/users/#{@user_id}"
    expect(page).to have_current_path(events_url)
  end

  after(:all) do
    User.delete_all
  end
end
