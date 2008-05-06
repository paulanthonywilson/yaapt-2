class Story < ActiveRecord::Base  
  validates_presence_of :title
  validates_inclusion_of :status, :in=>['unstarted', 'in_progress', 'done'], :message=>'can only be unstarted in progress or done'
end
