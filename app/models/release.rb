class Release < ActiveRecord::Base
  validates_presence_of :release_date
  
  def description
    "#{release_date} - #{name}"
  end
end
