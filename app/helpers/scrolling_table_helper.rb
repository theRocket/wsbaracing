module ScrollingTableHelper
  def scrolling_table(&block)
    record_type = controller.controller_name
    table = ScrollingTable.new
    yield(table)
    render :partial => "shared/scrolling_table/base", :locals => { :record_type => record_type.singularize, :records => assigns[record_type], :columns => table.columns }
  end
end
