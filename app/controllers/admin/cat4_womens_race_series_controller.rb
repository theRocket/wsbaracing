class Admin::Cat4WomensRaceSeriesController < ApplicationController

  before_filter :login_required
  layout 'admin/application'
  
  def new_result
    @result = Result.new(params[:result])
  end
  
  def create_result
    begin
      event_for_find = SingleDayEvent.new(params[:event])
      @event = SingleDayEvent.find(:first, :conditions => { :name => event_for_find.name, :date => event_for_find.date })
      if @event.nil?
        @event = SingleDayEvent.new(params[:event])
        unless params[:event][:sanctioned_by]
          @event.sanctioned_by = nil 
        end
        @event.save!
      end

      @standings =  @event.standings.detect {|s| !s.is_a?(CombinedStandings) }
      if @standings.nil?
        @standings = @event.standings.create! 
      end
      
      cat_4_women = Category.find_by_name("Category 4 Women")
      @race = @standings.races.detect do |r|
        r.category == cat_4_women || cat_4_women.descendants.include?(r.category)
      end
      if @race.nil?
        @race = @standings.races.create!(:category => cat_4_women)
      end
      
      @result = @race.results.create!(params[:result])
      
      flash[:info] = "Created result for #{@result.name} in #{@event.name}"
      redirect_to(:action => "new_result", :result => { 
                                                        :first_name => params[:result][:first_name],
                                                        :last_name => params[:result][:last_name],
                                                        :team_name => params[:result][:team_name],
                                                         })
    rescue Exception => e
      logger.debug(e)
      logger.debug(e.backtrace.join("\n")) if logger.debug?
      render(:action => "new_result")
    end
  end
end