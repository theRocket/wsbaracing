module ScrollingTableHelper
  def scrolling_table(&block)
    table = ScrollingTable::Base.new(controller.controller_name)
    table.records = assigns[controller.controller_name]
    yield(table)
    render :partial => "shared/scrolling_table/base", :locals => { :scrolling_table => table }
  end
  
  # Inline
  # TODO Updated test for cancel
  # TODO Better UI clean on exception
  def merge
    begin
      record_to_merge_id = params[:id]
      @plural_record_type = controller_name
      record_class = controller_name.classify.constantize
      @record_to_merge = record_class.find(record_to_merge_id)
      @merged_record_name = @record_to_merge.name
      @existing_record = record_class.find(params[:target_id])
      @existing_record.merge(@record_to_merge)
      @record_type = @plural_record_type.singularize
      expire_cache
      render :template => "shared/scrolling_table/merge"
    rescue Exception => e
      logger.error(e)
      render :update do |page|
        page.visual_effect(:highlight, "#{@record_type}_#{@existing_record.id}_row", :startcolor => "#ff0000", :endcolor => "#FFDE14") if @existing_record
        page.alert("Could not merge #{@plural_record_type}.\n#{e}")
      end
      ExceptionNotifier.deliver_exception_notification(e, self, request, {})
    end
  end
end
