class ScrollingTable
  def column(title)
    columns << ScrollingTableColumn.new(title)
  end
  
  def columns
    @columns ||= []
  end
end