require File.dirname(__FILE__) + '/../../test_helper'

module ScrollingTable
  class ColumnTableTest < ActiveSupport::TestCase
    def test_new
      column = ScrollingTable::Column.new("Name")
      assert_equal("Name", column.title, "title")
      assert_equal("name", column.style_class, "style_class")
    end

    def test_options
      column = ScrollingTable::Column.new("Team", :style_class => "team_name")
      assert_equal("Team", column.title, "title")
      assert_equal("team_name", column.style_class, "style_class")
    end
  end
end
