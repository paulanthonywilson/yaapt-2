class Release < ActiveRecord::Base
  has_many :stories
  validates_presence_of :release_date
  
  def description
    return release_date.to_s if name.blank?
    "#{release_date} - #{name}"
  end
  
  class << self
    def done
      find(:all, :conditions=>'done=true', :order=>'release_date DESC')
    end
    
    def todo
      find(:all, :conditions=>'done=false', :order=>'release_date DESC')
    end
    
  end
end
