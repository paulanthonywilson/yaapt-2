class BurndownGraph
  attr_writer :title, :histories, :release_date, :start_date

  def initialize(&block)
    @histories=[]
    yield self if block_given?
  end

  def to_gruff
    g = Gruff::AllLabelLine.new(650)
    g.hide_dots = true
    g.hide_legend = true
    g.title = @title
    if @histories.empty?
      return g
    end
    histories_to_graph = GraphedHistories.new(@histories).
    constrained_to_release_date(@release_date).
    constrained_to_start_date(@start_date)
    g.data("burndown", histories_to_graph.map(&:left_todo))
    g.minimum_value=0
    g.labels = histories_to_graph.labels
    g
  end




  private

  class GraphedHistories < Array
    @@date_and_total = Struct.new(:date, :left_todo)
    def initialize(histories)
      super inflate(histories)
    end

    def constrained_to_release_date(release_date)
      do_not_graph_after release_date
      fill_to release_date
      self
    end

    def constrained_to_start_date(start_date)
      do_not_graph_before start_date if start_date
      self
    end

    def labels
      labels = {}
      1.step(size, size / 3.0) {|i| labels[i.round - 1]=self[i.round - 1].date.strftime('%d %b %Y')}
      labels[size - 1] = last.date.strftime('%d %b %Y')
      labels
    end


    private

    def inflate(compressed)
      compressed.inject([]) do |expanded, history|
        unless expanded.empty?
          expanded.last.date.tomorrow.upto(history.date.yesterday) do |missing_date|
            expanded << @@date_and_total.new(missing_date, expanded.last.left_todo)
          end
        end
        expanded << history
      end
    end

    def fill_to(date)
      unless empty?
        today = Date::today
        while(last.date < date) do
          next_date = last.date.tomorrow
          self << @@date_and_total.new(next_date, next_date < today ? last.left_todo : nil)
        end
      end
    end

    def do_not_graph_after(release_date)
      reject! {|history| history.date > release_date}
    end

    def do_not_graph_before start_date
      reject! {|history| history.date < start_date}
    end

  end

end

class Gruff::AllLabelLine < Gruff::Line
  def draw
    super
    return unless @has_data
    @norm_data.each do |data_row|      
      data_row[1].each_with_index do |data_point, index|
        draw_label( @graph_left + (@x_increment * index), index)  if data_point.nil?
      end
    end
  end
end
