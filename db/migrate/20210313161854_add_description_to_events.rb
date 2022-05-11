class AddDescriptionToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :Description, :string
  end
end
