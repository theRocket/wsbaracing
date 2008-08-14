class ScrollingTableColumn
  attr_reader :title, :style_class

  def initialize(title)
    @title = title
    @style_class = title.downcase
  end
end