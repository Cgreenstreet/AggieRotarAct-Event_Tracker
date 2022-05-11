class CreatePoints < ActiveRecord::Migration[6.1]
  def change
    add_reference :events, :event, index: true, foreign_key: true, optional: true 
    add_reference :users, :user, index: true, foreign_key: true, type: :uuid
    create_table :points, id: :uuid do |t|
      t.datetime :date
      t.string :name
      t.integer :number
      t.string :type

      t.timestamps
    end
  end
end
