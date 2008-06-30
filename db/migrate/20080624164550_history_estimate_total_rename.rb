class HistoryEstimateTotalRename < ActiveRecord::Migration
  def self.up
    rename_column :release_histories, :estimate_total, :total_todo
  end

  def self.down
    rename_column :release_histories, :total_todo, :estimate_total
  end
end
