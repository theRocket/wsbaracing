module ScrollingTableHelper
  def scrolling_table(&block)
    table = ScrollingTable.new(controller.controller_name)
    table.records = assigns[controller.controller_name]
    yield(table)
    render :partial => "shared/scrolling_table/base", :locals => { :scrolling_table => table }
  end
end
