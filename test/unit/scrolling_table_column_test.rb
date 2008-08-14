require File.dirname(__FILE__) + '/../test_helper'

class ScrollingColumnTableTest < ActiveSupport::TestCase
  def test_new
    column = ScrollingTableColumn.new("Name")
    assert_equal("Name", column.title, "title")
    assert_equal("name", column.style_class, "style_class")
  end
end