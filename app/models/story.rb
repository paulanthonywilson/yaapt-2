class Story < ActiveRecord::Base  
  validates_presence_of :title
  validates_inclusion_of :status, :in=>['unstarted', 'in_progress', 'done']
end
