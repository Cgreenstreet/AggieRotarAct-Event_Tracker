class ChangeNumberTypeInPoints < ActiveRecord::Migration[6.1]
  def up
    change_table :points do |t|
      t.change :number, :decimal
    end
  end
  def down
    change_table :points do |t|
      t.change :number, :integer
    end
  end
end
