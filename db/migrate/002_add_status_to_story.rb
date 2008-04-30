class AddStatusToStory < ActiveRecord::Migration
  def self.up   
    add_column :stories, :status, :string , :default=>'unstarted'
  end

  def self.down
    remove_column :stories, :status
  end
end
