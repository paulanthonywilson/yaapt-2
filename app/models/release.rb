class Release < ActiveRecord::Base
  has_many :stories
  has_many :release_histories, :order=>'history_date'
  validates_presence_of :release_date

  def description
    return release_date.to_s if name.blank?
    "#{release_date} - #{name}"
  end

  def estimate_total
    stories.reject(&:done?).map{|story| story.estimate ? story.estimate : 0}.sum
  end

  def notify_story_change
    history_today = release_histories.find_by_history_date(Date::today)
    if (history_today)
      history_today.update_attributes(:estimate_total=>estimate_total)
    else
      release_histories.create(:estimate_total=>estimate_total, :history_date=>Date::today)
    end
  end

  def to_burndown_graph
    BurndownGraph.new do |g|
      g.title = description
      g.release_date = release_date
      g.histories = release_histories
    end.to_gruff
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
