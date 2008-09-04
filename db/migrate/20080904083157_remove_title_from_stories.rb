class Story < ActiveRecord::Base
  def body_to_append
    return "" if body.blank?
    "\n#{self.body}"
  end
end

class RemoveTitleFromStories < ActiveRecord::Migration
  def self.up
    Story.find(:all).each do |story|
      story.update_attributes(:body => story.title + story.body_to_append)
    end
    remove_column :stories, :title
  end

  def self.down
    add_column :stories, :title, :string
  end
end
