require File.dirname(__FILE__) + '/../test_helper'

class ScrollingTableTest < ActiveSupport::TestCase
  def test_new
    table = ScrollingTable.new("racers")
    assert_not_nil(table.columns, "columns")
    assert_equal("racer", table.record_type, "record_type")
    assert_not_nil(table.records, "records")
  end
  
  def test_column
    table = ScrollingTable.new("racers")
    table.column("Name")
    table.column("Member")
    assert_equal(2, table.columns.size, "columns")
  end
  
  def test_column_with_options
    table = ScrollingTable.new("racers")
    table.column("Name", :style_class => "category_name")
    assert_equal(1, table.columns.size, "columns")
    assert_equal("category_name", table.columns.first.style_class, "style_class")
  end
end