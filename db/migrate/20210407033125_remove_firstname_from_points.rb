class RemoveFirstnameFromPoints < ActiveRecord::Migration[6.1]
  def change
    remove_column :points, :firstname, :string
  end
end
