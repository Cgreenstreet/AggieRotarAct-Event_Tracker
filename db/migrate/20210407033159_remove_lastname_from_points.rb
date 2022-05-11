class RemoveLastnameFromPoints < ActiveRecord::Migration[6.1]
  def change
    remove_column :points, :lastname, :string
  end
end
