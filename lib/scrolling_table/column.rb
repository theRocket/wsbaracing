module ScrollingTable
  class Column
    attr_reader :title, :style_class

    def initialize(title, *options)
      options = options.extract_options!
      @title = title
      @style_class = options[:style_class] || title.downcase
    end
  end
end