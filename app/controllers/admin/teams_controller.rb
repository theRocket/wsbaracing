class Admin::TeamsController < ApplicationController
  include ScrollingTableHelper
  
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
  
  # Inline
  def edit_name
    @team = Team.find(params[:id])
    render(:partial => "edit_name")
  end

  # Cancel inline editing
  def cancel_edit_name
    @team = Team.find(params[:id])
    render(:partial => 'name', :locals => { :team => @team })
  end
  
  # Inline update. Merge with existing Team if names match
  def update_name
    new_name = params[:name]
    team_id = params[:id]
    @team = Team.find(team_id)
    begin
      original_name = @team.name
      @team.name = new_name
      existing_teams = Team.find_all_by_name(new_name) | Alias.find_all_teams_by_name(new_name)
      existing_teams.reject! { |team| team == @team }
      if existing_teams.size > 0
        return merge?(original_name, existing_teams, @team)
      end

      if @team.save
        expire_cache
        render :update do |page| page.replace_html("team_#{@team.id}", :partial => 'name', :locals => { :team => @team }) end
      else
        render :update do |page|
          page.replace_html("team_#{@team.id}", :partial => 'edit', :locals => { :team => @team })
          @team.errors.full_messages.each do |message|
            page.insert_html(:after, "team_#{@team.id}_row", :partial => 'error', :locals => { :error => message })
          end
        end
      end
    rescue Exception => e
      ExceptionNotifier.deliver_exception_notification(e, self, request, {})
      render :update do |page|
        if @team
          page.insert_html(:after, "team_#{@team.id}_row", :partial => 'error', :locals => { :error => e })
        else
          page.alert(e.message)
        end
      end
    end
  end

  # Inline
  def merge?(original_name, existing_teams, team)
    @team = team
    @existing_teams = existing_teams
    @original_name = original_name
    render :update do |page| 
      page.replace_html("team_#{@team.id}", :partial => 'merge_confirm', :locals => { :team => @team })
    end
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

  # Exact dupe of racers controller
  def destroy_alias
    alias_id = params[:alias_id]
    Alias.destroy(alias_id)
    render :update do |page|
      page.visual_effect(:puff, "alias_#{alias_id}", :duration => 2)
    end
  end
end
