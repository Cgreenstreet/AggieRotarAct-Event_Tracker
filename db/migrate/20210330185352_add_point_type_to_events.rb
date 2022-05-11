class AddPointTypeToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :PointType, :string
  end
end
