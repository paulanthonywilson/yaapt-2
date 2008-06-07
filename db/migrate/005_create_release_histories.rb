class CreateReleaseHistories < ActiveRecord::Migration
  def self.up
    create_table :release_histories do |t|
      t.date :history_date
      t.integer :estimate_total
      t.integer :release_id
      t.timestamps
    end
  end

  def self.down
    drop_table :release_histories
  end
end
