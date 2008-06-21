class ReleaseHistory < ActiveRecord::Base
  belongs_to :release
  
  
  def date 
    history_date
  end
  
  def date= value
    self.history_date = value
  end
end
