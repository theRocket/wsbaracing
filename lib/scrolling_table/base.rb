module ScrollingTable
  class Base
    attr_reader :columns, :plural_record_type, :record_type
    attr_accessor :buttons, :records

    def initialize(plural_record_type)
      @plural_record_type = plural_record_type
      @record_type = plural_record_type.singularize
      @records = []
      @buttons = []
      @columns = []
    end

    def button(title, *options)
      buttons << Button.new(title, options.extract_options!)
    end

    def column(title, *options)
      columns << Column.new(title, options.extract_options!)
    end
  end
end
