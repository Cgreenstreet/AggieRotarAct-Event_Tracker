class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.integer :ID
      t.string :Name
      t.datetime :Date
      t.string :Location
      t.numeric :Points

      t.timestamps
    end
  end
end
