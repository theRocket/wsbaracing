require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  
  def test_include
    category = Category.create(:name => 'Sandbaggers')
    assert(category.include?(category), 'category should include itself')
    assert(!category.include?(nil), 'category should not include nil')
    assert(!category.include?(categories(:senior_men)), 'category should not include Senior Men')
    
    competition_category = category.competition_categories.create(:source_category => categories(:senior_men))
    assert(category.include?(category), 'category should still include itself')
    assert(category.include?(categories(:senior_men)), 'category should include senior men')
  end
end
