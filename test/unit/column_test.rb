require File.dirname(__FILE__) + '/../test_helper'

class ColumnTest < Test::Unit::TestCase
  
  def test_create
    column = Column.new("place", "place")
    assert_equal("place", column.name, "Name after create")
    assert_equal(:place, column.field, "Field after create")
  end
end