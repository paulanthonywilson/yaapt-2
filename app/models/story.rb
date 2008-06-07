class Story < ActiveRecord::Base  
  validates_presence_of :title
  validates_inclusion_of :status, :in=>['unstarted', 'in_progress', 'done']
  belongs_to :release


  def after_find
    @release_on_find = release
  end
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
  
  def self.unassigned
    find(:all, :conditions=>'release_id is null')
  end
  

  
  def after_save
    release.notify_story_change if release
    @release_on_find.notify_story_change if @release_on_find unless @release_on_find == release
  end
  
  def done?
    status == 'done'
  end
    

end
