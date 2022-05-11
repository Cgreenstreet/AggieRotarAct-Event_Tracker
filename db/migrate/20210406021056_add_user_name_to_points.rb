class AddUserNameToPoints < ActiveRecord::Migration[6.1]
  def change
    add_column :points, :firstname, :string
    add_column :points, :lastname, :string
  end
end
