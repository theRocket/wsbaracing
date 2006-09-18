require File.dirname(__FILE__) + '/../test_helper'

class PromoterTest < Test::Unit::TestCase
  
  fixtures :promoters

  def test_find_by_info
    assert_equal(promoters(:brad_ross), Promoter.find_by_info("Brad ross"))
    assert_equal(promoters(:brad_ross), Promoter.find_by_info("Brad ross", "brad@foo.com"))
    assert_equal(promoters(:candi_murray), Promoter.find_by_info("Candi Murray"))
    assert_equal(promoters(:candi_murray), Promoter.find_by_info("Candi Murray", "candi@obra.org", "(503) 555-1212"))
    assert_equal(promoters(:candi_murray), Promoter.find_by_info("", "candi@obra.org", "(503) 555-1212"))
    assert_equal(promoters(:candi_murray), Promoter.find_by_info("", "candi@obra.org"))

    assert_nil(Promoter.find_by_info("", "mike_murray@obra.org", "(451) 324-8133"))
    assert_nil(Promoter.find_by_info("", "membership@obra.org"))
    
    promoter = Promoter.new(:phone => "(212) 522-1872")
    promoter.save!
    assert_equal(promoter, Promoter.find_by_info("", "", "(212) 522-1872"))
    
    promoter = Promoter.new(:email => "cjw@cjw.net")
    promoter.save!
    assert_equal(promoter, Promoter.find_by_info("", "cjw@cjw.net", ""))
  end
  
  def test_save_no_name
    nate_hobson = promoters(:nate_hobson)
    nate_hobson.save!
  end
end