class FixColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :points, :type, :point_type
  end
end
