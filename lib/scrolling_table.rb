class ScrollingTable
  attr_reader :columns, :record_type
  attr_accessor :records
  
  def initialize(record_type)
    @record_type = record_type.singularize
    @records = []
    @columns = []
  end
  
  def column(title, *options)
    columns << ScrollingTableColumn.new(title, options.extract_options!)
  end
end