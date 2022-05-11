class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :google_id
      t.string :email
      t.string :uin
      t.string :phone
      t.string :first_name
      t.string :last_name
      t.boolean :officer
      t.numeric :points
      t.timestamps
    end
  end
end
