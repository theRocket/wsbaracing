class ScrollingTable
  attr_reader :columns, :plural_record_type, :record_type
  attr_accessor :records
  
  def initialize(plural_record_type)
    @plural_record_type = plural_record_type
    @record_type = plural_record_type.singularize
    @records = []
    @columns = []
  end
  
  def column(title, *options)
    columns << ScrollingTableColumn.new(title, options.extract_options!)
  end
end