require File.dirname(__FILE__) + '/../test_helper'

class ScrollingTableTest < ActiveSupport::TestCase
  def test_new
    table = ScrollingTable.new
    assert_not_nil(table.columns, "columns")
  end
  
  def test_column
    table = ScrollingTable.new
    table.column("Name")
    table.column("Member")
    assert_equal(2, table.columns.size, "columns")
  end
end