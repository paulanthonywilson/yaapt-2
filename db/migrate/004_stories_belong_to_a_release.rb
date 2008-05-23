class StoriesBelongToARelease < ActiveRecord::Migration
  def self.up
    add_column 'stories', 'release_id', :int
  end

  def self.down
    remove_column 'stories', 'release_id'
  end
end
