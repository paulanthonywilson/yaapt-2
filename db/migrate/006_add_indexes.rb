class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index(:stories, :release_id)
    add_index(:release_histories, [:release_id, :history_date])
  end

  def self.down
  end
end
