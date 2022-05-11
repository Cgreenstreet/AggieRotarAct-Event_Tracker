# frozen_string_literal: true

RSpec.describe User, type: :model do
  before(:all) do
    @member = User.new(google_id: 'member', email: 'member@example.com', first_name: 'John', last_name: 'Doe')
    @officer = User.new(google_id: 'officer', email: 'officer@example.com', first_name: 'Jane', last_name: 'Doe',
                        officer: true, uin: '123004567', phone: '555-555-5555')

    @member.save
    @officer.save
  end

  context 'validation test' do
    # Should require the following attributes: google_id, email, first_name, last_name

    it 'ensures Google ID presence' do
      user = User.new(email: 'unique@example.com', first_name: 'Jane', last_name: 'Doe').save
      expect(user).to eq(false)
    end

    it 'ensures Google ID uniqueness' do
      user = User.new(google_id: 'member', email: 'unique@example.com', first_name: 'Jane', last_name: 'Doe').save
      expect(user).to eq(false)
    end

    it 'ensures Email presence' do
      user = User.new(google_id: 'unique', first_name: 'Jane', last_name: 'Doe').save
      expect(user).to eq(false)
    end

    it 'ensures email uniqueness' do
      user = User.new(google_id: 'unique', email: 'member@example.com', first_name: 'Jane', last_name: 'Doe').save
      expect(user).to eq(false)
    end

    it 'ensures First Name presence' do
      user = User.new(google_id: 'unique', email: 'unique@example.com', last_name: 'Doe').save
      expect(user).to eq(false)
    end

    it 'ensures Last Name presence' do
      user = User.new(google_id: 'unique', email: 'unique@example.com', first_name: 'Jane').save
      expect(user).to eq(false)
    end

    it 'does not ensure other attributes' do
      user = User.new(google_id: 'unique', email: 'unique@example.com', first_name: 'Jane', last_name: 'Doe').save
      expect(user).to eq(true)
    end
  end

  describe 'id_from_google_id' do
    it 'returns a user\'s id if their google_id is in the database' do
      expect(User.id_from_google_id('member')).to eq(@member[:id])
    end

    it 'returns false if user does not have google_id' do
      expect(User.id_from_google_id('not_here')).to eq(nil)
    end
  end

  describe 'officer?' do
    it 'returns true if a user is an officer' do
      expect(User.officer?(@officer[:id])).to eq(true)
    end

    it 'returns false if user is not an officer' do
      expect(User.officer?(@member[:id])).to eq(false)
    end

    it 'returns false if user is not in the database' do
      expect(User.officer?(-1)).to eq(false)
    end
  end

  describe 'logged_in?' do
    it 'checks if a user id is in the database' do
      expect(User.logged_in?(-1)).to eq(false)
    end

    it 'checks to see if all attributes for a user are present' do
      expect(User.logged_in?(@member[:id])).to eq(false)
      expect(User.logged_in?(@officer[:id])).to eq(true)
    end
  end

  after(:all) do
    User.delete_all
  end
end
