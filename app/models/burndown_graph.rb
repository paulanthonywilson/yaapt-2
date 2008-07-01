class BurndownGraph
  attr_writer :title, :histories, :release_date, :start_date

  def initialize(&block)
    @histories=[]
    yield self if block_given?
  end

  def to_gruff(size=650)
    g = Gruff::AllLabelLine.new(size)
    g.hide_dots = true
    g.title = @title

    return g if @histories.empty?

    histories_to_graph = GraphedHistories.new(@histories).
    constrained_to_release_date(@release_date).
    constrained_to_start_date(@start_date)
    g.data("todo", histories_to_graph.map(&:total_todo))
    g.data("totals", histories_to_graph.map(&:total_estimate))
    g.minimum_value=0
    g.labels = histories_to_graph.labels
    g
  end




  private

  class GraphedHistories < Array
    @@date_and_total = Struct.new(:date, :total_todo, :total_estimate)
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
            expanded << @@date_and_total.new(missing_date, expanded.last.total_todo, expanded.last.total_estimate)
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
          if next_date < today
            self << @@date_and_total.new(next_date, last.total_todo, last.total_estimate)
          else
            self << @@date_and_total.new(next_date, nil, nil)
          end
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
