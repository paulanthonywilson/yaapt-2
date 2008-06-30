class RecordTotalEstimateInReleaseHistories < ActiveRecord::Migration
  def self.up
    add_column :release_histories, :total_estimate, :integer
  end

  def self.down
    remove_column :release_histories, :total_estimate
  end
end
