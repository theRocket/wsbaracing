class Admin::TeamsController < ApplicationController
  
  before_filter :login_required
  layout 'admin/application'

  def index
    @name = params['name'] || session['team_name'] || cookies[:team_name] || ''
    
    if @name.blank?
      @teams = []
      flash[:info] = "Enter part of a team's name"
    else
      session['team_name'] = @name
      cookies[:team_name] = {:value => @name, :expires => Time.now + 36000}
      
      @teams = Team.find_by_name_like(@name, RESULTS_LIMIT)

      if @teams.size == RESULTS_LIMIT
        flash[:warn] = "First #{RESULTS_LIMIT} teams"
      end
      
      if @teams.empty?
        flash[:info] = "No teams found"
      end
    end
  end
  
  def edit
    @team = Team.find(params[:id])
  end
  
  def toggle_member
    team = Team.find(params[:id])
    team.toggle!(:member)
    render(:partial => 'member', :locals => {:team => team})
  end

  def destroy
    @team = Team.find(params[:id])
    begin
      @team.destroy
      respond_to do |format|
        format.html {redirect_to admin_teams_path}
        format.js
      end
      expire_cache
    rescue  Exception => e
      render :update do |page|
        page.visual_effect(:highlight, "team_#{@team.id}_row", :startcolor => "#ff0000", :endcolor => "#FFDE14") if @existing_team
        page.alert("Could not delete #{@team.name}.\n#{e}")
      end
      ExceptionNotifier.deliver_exception_notification(e, self, request, {})
    end
  end
end
