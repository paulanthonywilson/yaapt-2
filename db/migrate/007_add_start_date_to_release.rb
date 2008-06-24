class AddStartDateToRelease < ActiveRecord::Migration
  def self.up
    add_column :releases, :start_date, :date
  end

  def self.down
    remove_column :releases, :start_date
  end
end
