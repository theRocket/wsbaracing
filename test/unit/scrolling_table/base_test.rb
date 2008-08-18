require File.dirname(__FILE__) + '/../../test_helper'

module ScrollingTable
  class BaseTest < ActiveSupport::TestCase
    def test_new
      table = ScrollingTable::Base.new("racers")
      assert_not_nil(table.columns, "columns")
      assert_equal("racer", table.record_type, "record_type")
      assert_equal("racers", table.plural_record_type, "plural_record_type")
      assert_not_nil(table.records, "records")
    end
  
    def test_column
      table = ScrollingTable::Base.new("racers")
      table.column("Name")
      table.column("Member")
      assert_equal(2, table.columns.size, "columns")
    end
  
    def test_column_with_options
      table = ScrollingTable::Base.new("racers")
      table.column("Name", :style_class => "category_name")
      assert_equal(1, table.columns.size, "columns")
      assert_equal("category_name", table.columns.first.style_class, "style_class")
    end
  
    def test_button
      table = ScrollingTable::Base.new("teams")
      table.button("Results")
      assert_equal(1, table.buttons.size, "buttons")
      assert_equal("results", table.buttons.first.name, "name")
      assert_equal("Results", table.buttons.first.value, "value")
      assert_equal("Results", table.buttons.first.text, "text")
      assert_equal("results_button", table.buttons.first.style_id, "style_id")
    end
  end
end