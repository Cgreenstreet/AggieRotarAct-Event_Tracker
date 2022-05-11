class CreateParticipations < ActiveRecord::Migration[6.1]
  def change
    create_table :participations, id: :uuid do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
