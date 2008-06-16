

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
    g = Gruff::Line.new(650)
    g.hide_dots = true
    g.hide_legend = true
    g.title = self.description
    if release_histories.empty?
      return g
    end
    date_and_total = Struct.new(:history_date, :estimate_total)
    data = release_histories.inject do |memo, obj| 
      memo = [memo] unless Array === memo
      while memo.last.history_date < obj.history_date.yesterday do
        memo << date_and_total.new(memo.last.history_date.tomorrow, memo.last.estimate_total)
      end
      memo << date_and_total.new(obj.history_date, obj.estimate_total)
      memo
    end
    data = [data] unless Array === data
    unless data.empty?
      while(data.last.history_date < release_date) do
        data << date_and_total.new(data.last.history_date.tomorrow, nil)
      end
    end
    g.data("burndown", data.map(&:estimate_total))

    labels = {}
    1.step(data.size, data.size / 3.0) {|i| labels[i.round - 1]=data[i.round - 1].history_date.strftime('%d %b %Y')}
    labels[data.size - 1] = data.last.history_date.strftime('%d %b %Y')
    g.labels = labels
    g.minimum_value=0
    g
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
