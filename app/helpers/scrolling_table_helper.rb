module ScrollingTableHelper
  def scrolling_table(name, columns)
    record_type = name.to_s.singularize
    render :partial => "shared/scrolling_table/base", :locals => { :record_type => record_type, :records => assigns[name.to_s], :columns => columns }
  end
end