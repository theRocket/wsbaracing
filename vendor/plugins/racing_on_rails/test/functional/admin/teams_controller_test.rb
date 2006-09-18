require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/teams_controller'

class Admin::TeamsController; def rescue_action(e) raise e end; end

class Admin::TeamsControllerTest < Test::Unit::TestCase

  fixtures :teams, :racers, :aliases, :users, :promoters, :events, :disciplines, :aliases_disciplines
  
  def setup
    @controller = Admin::TeamsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
  end
  
  def test_not_logged_in_index
    get(:index)
    assert_response(:redirect)
    assert_redirect_url "http://localhost/admin/account/login"
    assert_nil(@request.session["user"], "No user in session")
  end
  
  def test_not_logged_in_edit
    vanilla = teams(:vanilla)
    get(:edit_name, :id => vanilla.to_param)
    assert_response(:redirect)
    assert_redirect_url "http://localhost/admin/account/login"
    assert_nil(@request.session["user"], "No user in session")
  end

  def test_index
    @request.session[:user] = users(:candi)
    opts = {:controller => "admin/teams", :action => "index"}
    assert_routing("/admin/teams", opts)
    
    get(:index)
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert(assigns["teams"].empty?, "Should have no racers")
    assert_not_nil(assigns["name"], "Should assign name")
  end

  def test_find
    @request.session[:user] = users(:candi)
    get(:index, :name => 'van')
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal([teams(:vanilla)], assigns['teams'], 'Search for van should find Vanilla')
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('van', assigns['name'], "'name' assigns")
  end
  
  def test_find_nothing
    @request.session[:user] = users(:candi)
    get(:index, :name => 's7dfnacs89danfx')
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal(0, assigns['teams'].size, "Should find no teams")
  end
  
  def test_find_empty_name
    @request.session[:user] = users(:candi)
    get(:index, :name => '')
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal(0, assigns['teams'].size, "Search for '' should find no teams")
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('', assigns['name'], "'name' assigns")
  end

  def test_find_limit
    for i in 0..Admin::TeamsController::RESULTS_LIMIT
      Team.create(:name => "Test Team #{i}")
    end
    @request.session[:user] = users(:candi)
    get(:index, :name => 'Test')
    assert_response(:success)
    assert_template("admin/teams/index")
    assert_not_nil(assigns["teams"], "Should assign teams")
    assert_equal(Admin::TeamsController::RESULTS_LIMIT, assigns['teams'].size, "Search for '' should find all teams")
    assert_not_nil(assigns["name"], "Should assign name")
    assert(!flash.empty?, 'flash not empty?')
    assert_equal('Test', assigns['name'], "'name' assigns")
  end
  
  def test_edit_name
    @request.session[:user] = users(:candi)
    vanilla = teams(:vanilla)
    get(:edit_name, :id => vanilla.to_param)
    assert_response(:success)
    assert_template("admin/teams/_edit")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
  end

  def test_blank_name
    @request.session[:user] = users(:candi)
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => '')
    assert_response(:success)
    assert_template("admin/teams/_edit")
    assert_not_nil(assigns["team"], "Should assign team")
    assert(!assigns["team"].errors.empty?, 'Attempt to assign blank name should add error')
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('Vanilla', vanilla.name, 'Team name after cancel')
  end

  def test_cancel
    @request.session[:user] = users(:candi)
    vanilla = teams(:vanilla)
    original_name = vanilla.name
    get(:cancel, :id => vanilla.to_param, :name => vanilla.name)
    assert_response(:success)
    assert_template("admin/teams/_team")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal(original_name, vanilla.name, 'Team name after cancel')
  end

  def test_update
    @request.session[:user] = users(:candi)
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => 'Vaniller')
    assert_response(:success)
    assert_template("admin/teams/_team")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('Vaniller', vanilla.name, 'Team name after update')
  end
  
  def test_update_same_name
    @request.session[:user] = users(:candi)
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => 'Vanilla')
    assert_response(:success)
    assert_template("admin/teams/_team")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('Vanilla', vanilla.name, 'Team name after update')
  end
  
  def test_update_same_name_different_case
    @request.session[:user] = users(:candi)
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => 'vanilla')
    assert_response(:success)
    assert_template("admin/teams/_team")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('vanilla', vanilla.name, 'Team name after update')
  end
  
  def test_update_to_existing_name
    # Should ask to merge
    @request.session[:user] = users(:candi)
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => 'Kona')
    assert_response(:success)
    assert_template("admin/teams/_merge_confirm")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla still in database')
    assert_not_nil(Team.find_by_name('Kona'), 'Kona still in database')
    vanilla.reload
    assert_equal('Vanilla', vanilla.name, 'Team name after cancel')
  end
  
  def test_update_to_existing_alias
    vanilla_alias = Alias.find_by_name('Vanilla')
    assert_nil(vanilla_alias, 'Alias')

    @request.session[:user] = users(:candi)
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => 'Vanilla Bicycles')
    assert_response(:success)
    assert_template("admin/teams/_team")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('Vanilla Bicycles', vanilla.name, 'Team name after cancel')
    vanilla_alias = Alias.find_by_name('Vanilla')
    assert_not_nil(vanilla_alias, 'Alias')
    assert_equal(vanilla, vanilla_alias.team, 'Alias team')
    old_vanilla_alias = Alias.find_by_name('Vanilla Bicycles')
    assert_nil(old_vanilla_alias, 'Alias')
  end
  
  def test_update_to_existing_alias_different_case
    vanilla_alias = Alias.find_by_name('Vanilla')
    assert_nil(vanilla_alias, 'Alias')

    @request.session[:user] = users(:candi)
    vanilla = teams(:vanilla)
    post(:update, :id => vanilla.to_param, :name => 'vanilla bicycles')
    assert_response(:success)
    assert_template("admin/teams/_team")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(vanilla, assigns['team'], 'Team')
    vanilla.reload
    assert_equal('vanilla bicycles', vanilla.name, 'Team name after update')
    vanilla_alias = Alias.find_by_name('Vanilla')
    assert_not_nil(vanilla_alias, 'Alias')
    assert_equal(vanilla, vanilla_alias.team, 'Alias team')
    old_vanilla_alias = Alias.find_by_name('vanilla bicycles')
    assert_nil(old_vanilla_alias, 'Alias')
  end
  
  def test_update_to_other_team_existing_alias
    @request.session[:user] = users(:candi)
    kona = teams(:kona)
    post(:update, :id => kona.to_param, :name => 'Vanilla Bicycles')
    assert_response(:success)
    assert_template("admin/teams/_merge_confirm")
    assert_not_nil(assigns["team"], "Should assign team")
    assert_equal(kona, assigns['team'], 'Team')
    assert_equal('Vanilla Bicycles', assigns['existing_team_name'], 'existing_team_name')
    assert_not_nil(Team.find_by_name('Kona'), 'Kona still in database')
    assert_not_nil(Team.find_by_name('Vanilla'), 'Vanilla still in database')
    assert_nil(Team.find_by_name('Vanilla Bicycles'), 'Vanilla Bicycles not in database')
  end
  
  def test_destroy
    @request.session[:user] = users(:candi)
    csc = Team.create(:name => 'CSC')
    post(:destroy, :id => csc.id, :commit => 'Delete')
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'CSC should have been destroyed') { Team.find(csc.id) }
  end
  
  def test_merge?
    @request.session[:user] = users(:candi)
    vanilla = teams(:vanilla)
    kona = teams(:kona)
    get(:update, :name => vanilla.name, :id => kona.to_param)
    assert_response(:success)
    assert_template("admin/teams/_merge_confirm")
    assert_equal(kona, assigns['team'], 'Team')
    assert_equal(vanilla.name, assigns['team'].name, 'Unsaved Kona name should be Vanilla')
    assert_equal(vanilla, assigns['existing_team'], 'Existing Team')
  end
  
  def test_merge
    vanilla = teams(:vanilla)
    kona = teams(:kona)
    old_id = kona.id
    assert(Team.find_by_name('Kona'), 'Kona should be in database')

    @request.session[:user] = users(:candi)
    get(:merge, :id => kona.to_param, :target_id => vanilla.id)
    assert_response(:success)
    assert_template("admin/teams/merge")

    assert(Team.find_by_name('Vanilla'), 'Vanilla should be in database')
    assert_nil(Team.find_by_name('Kona'), 'Kona should not be in database')
  end

  def test_new_inline
    @request.session[:user] = users(:candi)
    opts = {:controller => "admin/teams", :action => "new_inline"}
    assert_routing("/admin/teams/new_inline", opts)
  
    get(:new_inline)
    assert_response(:success)
    assert_template("/admin/_new_inline")
    assert_not_nil(assigns["record"], "Should assign team as 'record'")
    assert_not_nil(assigns["icon"], "Should assign 'icon'")
  end

  def test_update_obra_member
    @request.session[:user] = users(:candi)
    vanilla = teams(:vanilla)
    assert_equal(true, vanilla.obra_member, 'obra_member before update')
    post(:toggle_attribute, :id => vanilla.to_param, :attribute => 'obra_member')
    assert_response(:success)
    assert_template("/admin/_attribute")
    vanilla.reload
    assert_equal(false, vanilla.obra_member, 'obra_member after update')

    vanilla = teams(:vanilla)
    post(:toggle_attribute, :id => vanilla.to_param, :attribute => 'obra_member')
    assert_response(:success)
    assert_template("/admin/_attribute")
    vanilla.reload
    assert_equal(true, vanilla.obra_member, 'obra_member after second update')
  end
end