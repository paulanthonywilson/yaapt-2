class Story < ActiveRecord::Base  
  validates_presence_of :title
  validates_inclusion_of :status, :in=>['unstarted', 'in_progress', 'done'], :message=>'can only be unstarted in progress or done'

  # Advance to the next status and save, returning true if save is succesful. If there is no valid next status do nothing
  # and return false
  def advance!
    if next_status
      self.status = next_status
      return save
    end
  end

  def next_status
    case(status)
    when 'unstarted'; 'in_progress'
    when 'in_progress'; 'done'
    end
  end

end
