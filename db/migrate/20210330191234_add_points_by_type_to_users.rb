class AddPointsByTypeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :meeting_points, :decimal
    add_column :users, :event_points, :decimal
    add_column :users, :social_points, :decimal
    add_column :users, :other_points, :decimal
    remove_column :users, :points, :integer
  end
end
