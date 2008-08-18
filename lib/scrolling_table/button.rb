module ScrollingTable
  class Button
    attr_reader :name, :style_id, :text, :value

    def initialize(text, *options)
      options = options.extract_options!
      @text = text
      @name = options[:name] || text.downcase
      @style_id = options[:style_id] || "#{@name}_button"
      @value = options[:value] || @text
    end
  end
end