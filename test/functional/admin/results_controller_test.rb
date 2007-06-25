require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/results_controller'

# Re-raise errors caught by the controller.
class Admin::ResultsController; def rescue_action(e) raise e end; end

class Admin::ResultsControllerTest < Test::Unit::TestCase

  def setup
    @controller = Admin::ResultsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = users(:candi)    
  end
  
  def test_destroy
    result_2 = results(:weaver_banana_belt)
    race = result_2.race
    event = race.standings.event
    assert_not_nil(result_2, 'Result should exist in DB')
    
    opts = {:controller => "admin/results", :action => "destroy", :id => result_2.to_param.to_s}
    assert_routing("/admin/results/destroy/#{result_2.to_param}", opts)
    post(:destroy, :id => result_2.to_param.to_s)
    
    assert(flash.has_key?(:notice))
    assert_response(:redirect)
    assert_redirected_to(
      :controller => "admin/events", 
      :action => :show, 
      :id => event.to_param,
      :race_id => race.to_param
    )

    assert_raise(ActiveRecord::RecordNotFound, 'Result should not exist in DB') {Result.find(result_2.id)}
  end
  
  def test_create
    kings_valley_pro_1_2 = races(:kings_valley_pro_1_2)
    existing_result_count = kings_valley_pro_1_2.results.size
    kings_valley = events(:kings_valley)
    
    opts = {:controller => "admin/results", :action => "create", :id => kings_valley_pro_1_2.to_param.to_s}
    assert_routing("/admin/results/create/#{kings_valley_pro_1_2.to_param}", opts)
    
    place = 'DQ'
    number = '400B'
    first_name = 'Erik'
    last_name = 'Tonkin'
    team_name = 'Lizard of the Toast'
    points = '20.5'
    time = '01:25:59.99'
    notes = 'centerline'
    
    post(:create, 
      :id => kings_valley_pro_1_2.to_param.to_s,
      :result => {
        :place => place,
        :number => number,
        :first_name => first_name,
        :last_name => last_name,
        :team_name => team_name,
        :points => points,
        :time_s => time,
        :notes => notes
      }
    )
    
    assert(flash.has_key?(:notice))
    assert_response(:redirect)
    assert_redirected_to(
      :controller => "admin/events", 
      :action => :show, 
      :id => kings_valley.to_param,
      :race_id => kings_valley_pro_1_2.to_param
    )
    
    kings_valley_pro_1_2.reload
    assert_equal(existing_result_count + 1, kings_valley_pro_1_2.results.size, 'Kings Valley 1/2 race results')
    new_result = kings_valley_pro_1_2.results.detect do |result|
      result.number == '400B'
    end
    assert_equal(place, new_result.place, 'place')
    assert_equal(points.to_f, new_result.points, 'points')
    assert_equal(time, new_result.time_s, 'time')
    assert_equal(notes, new_result.notes, 'notes')
    assert_equal(first_name, new_result.first_name, 'first_name')
    assert_equal(last_name, new_result.last_name, 'last_name')
    assert_equal(team_name, new_result.team_name, 'team_name')

    # no number, no place
    post(:create, 
      :id => kings_valley_pro_1_2.to_param.to_s,
      :result => {
        :first_name => 'first_name',
        :last_name => 'last_name',
        :team_name => team_name
      }
    )
    
    assert(flash.has_key?(:notice))
    assert_response(:redirect)
    assert_redirected_to(
      :controller => "admin/events", 
      :action => :show, 
      :id => kings_valley.to_param,
      :race_id => kings_valley_pro_1_2.to_param
    )
    
    kings_valley_pro_1_2.reload
    assert_equal(existing_result_count + 2, kings_valley_pro_1_2.results.size, 'Kings Valley 1/2 race results')
  end

  def test_new_inline
    opts = {:controller => "admin/results", :action => "new_inline"}
    assert_routing("/admin/results/new_inline", opts)
  
    get(:new_inline)
    assert_response(:success)
    assert_template("/admin/_new_inline")
    assert_not_nil(assigns["record"], "Should assign result as 'record'")
    assert_not_nil(assigns["icon"], "Should assign 'icon'")
  end
  
  def test_edit
    weaver_jack_frost = results(:weaver_jack_frost)
    opts = {:controller => "admin/results", :action => "edit", :id => weaver_jack_frost.to_param.to_s}
    assert_routing("/admin/results/edit/#{weaver_jack_frost.to_param}", opts)

    get(:edit, :id => weaver_jack_frost.to_param.to_s)
    
    assert_not_nil(assigns["result"], "Should assign result")
  end
  
  def test_update
    weaver_jack_frost = results(:weaver_jack_frost)
    assert_equal('9', weaver_jack_frost.place, 'place')
    assert_equal(0, weaver_jack_frost.points, 'points')
    assert_equal(1801, weaver_jack_frost.time, 'time')
    assert_equal(nil, weaver_jack_frost.notes, 'notes')
    assert_equal('Ryan', weaver_jack_frost.first_name, 'first_name')
    assert_equal('Weaver', weaver_jack_frost.last_name, 'last_name')
    assert_equal('', weaver_jack_frost.team_name, 'team_name')

    opts = {:controller => "admin/results", :action => "update", :id => weaver_jack_frost.to_param.to_s}
    assert_routing("/admin/results/update/#{weaver_jack_frost.to_param}", opts)

    place = '12'
    number = '1233'
    first_name = 'Ryan B'
    last_name = 'Weavedog'
    team_name = 'River City'
    points = '1'
    time = '30:00'
    notes = 'flatted'
    
    post(:update, 
      :result => {
        :id => weaver_jack_frost.to_param.to_s,
        :place => place,
        :number => number,
        :first_name => first_name,
        :last_name => last_name,
        :team_name => team_name,
        :points => points,
        :time_s => time,
        :notes => notes
      }
    )
    
    assert_response(:redirect)
    assert_redirected_to(
      :controller => "admin/events", 
      :action => :show, 
      :id => weaver_jack_frost.race.standings.event.to_param,
      :race_id => weaver_jack_frost.race.to_param
    )
    assert(flash.has_key?(:notice))

    weaver_jack_frost.reload
    assert_equal(place, weaver_jack_frost.place, 'place')
    assert_equal(points.to_f, weaver_jack_frost.points, 'points')
    assert_equal('30:00.00', weaver_jack_frost.time_s, 'time')
    assert_equal(notes, weaver_jack_frost.notes, 'notes')
    assert_equal(first_name, weaver_jack_frost.first_name, 'first_name')
    assert_equal(last_name, weaver_jack_frost.last_name, 'last_name')
    assert_equal(team_name, weaver_jack_frost.team_name, 'team_name')
  end
  
  def test_racer
    weaver = racers(:weaver)
    opts = {:controller => "admin/results", :action => "racer", :id => weaver.to_param.to_s}
    assert_routing("/admin/results/racer/#{weaver.to_param}", opts)

    get(:racer, :id => weaver.to_param.to_s)
    
    assert_not_nil(assigns["results"], "Should assign results")
    assert_not_nil(assigns["racer"], "Should assign racer")
    assert_response(:success)
  end
  
  def test_find_racer
    opts = {:controller => "admin/results", :action => "find_racer"}
    assert_routing("/admin/results/find_racer", opts)

    post(:find_racer, :name => 'e', :left_racer_id => racers(:tonkin).id)
    
    assert_not_nil(assigns["name"], "Should assign name")
    assert_not_nil(assigns["racers"], "Should assign racers")
    assert_response(:success)
  end
  
  def test_find_racer_one_result
    weaver = racers(:weaver)
    opts = {:controller => "admin/results", :action => "find_racer"}
    assert_routing("/admin/results/find_racer", opts)

    post(:find_racer, :name => weaver.name, :left_racer_id => racers(:tonkin).id)
    
    assert_response(:redirect)
  end
  
  def test_select_racer
    opts = {:controller => "admin/results", :action => "select_racer"}
    assert_routing("/admin/results/select_racer", opts)

    weaver = racers(:weaver)
    get(:select_racer, :id => weaver.id, :name => 'Weaver', :left_racer_id => racers(:tonkin).id)
    
    assert_not_nil(assigns["name"], "Should assign name")
    assert_not_nil(assigns["results"], "Should assign results")
    assert_response(:success)
  end
  
  def test_move_result
    opts = {:controller => "admin/results", :action => "move_result"}
    assert_routing("/admin/results/move_result", opts)

    weaver = racers(:weaver)
    tonkin = racers(:tonkin)
    result = results(:tonkin_kings_valley)
    assert(tonkin.results.include?(result))
    assert(!weaver.results.include?(result))
    
    get(:move_result, :racer_id => weaver.id, :id => "result_#{result.id}")
    
    assert(!tonkin.results(true).include?(result))
    assert(weaver.results(true).include?(result))
    assert_response(:success)
  end
end
