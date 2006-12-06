require File.dirname(__FILE__) + '/../test_helper'

require "tempfile"

class GridFileTest < Test::Unit::TestCase

  def test_new
    assert_raise(ArgumentError) {GridFile.new(nil)}
  end

  def test_new_file
    file = File.new("#{File.dirname(__FILE__)}/../../test/fixtures/results/tabor.txt")
    grid_file = GridFile.new(file)
    assert_equal(35, grid_file.rows.size, "grid_file.rows.size")
    assert_equal("Dills", grid_file[20][3], "grid_file[20][3]")
  end
  
  def test_save
    file = Tempfile.new("test_results.txt")

    begin
      grid_file = GridFile.new(file)
      grid_file.rows = [
        ["Mary had a", "little"],
        ["", "lamb"]
      ]
      expected = [
        ["Mary had a", "little"],
        ["", "lamb"]
      ]
      assert_equal(expected, grid_file.rows, "unsaved file contents")
      grid_file.save
    ensure
      file.close if file && !file.closed?
    end
    expected = ["Mary had a\tlittle\n", "\tlamb\n"]
    begin
      file_to_read = File.new(file.path)
      lines = file_to_read.readlines
    ensure
      file_to_read.close if file_to_read && !file_to_read.closed?
    end
    
    assert_equal(expected, lines, "Saved file contents")
  end
end