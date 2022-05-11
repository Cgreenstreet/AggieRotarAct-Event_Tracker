class UsersForeignKeyForPoints < ActiveRecord::Migration[6.1]
  def change
    change_table :points do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
    end
  end
end
