module Competitions
  
  # WSBA rider rankings. Riders get points for top-10 finishes in any event
  class RiderRankings < Competition
    # FIXME Need to exclude non-members from the standings
    
    def RiderRankings.expire_cache
      FileUtils::rm_rf("#{RAILS_ROOT}/public/rider_rankings.html")
      FileUtils::rm_rf("#{RAILS_ROOT}/public/rider_rankings")
    end

    def friendly_name
      'Rider Rankings'
    end

    def point_schedule
      [0, 100, 70, 50, 40, 36, 32, 28, 24, 20, 16]
    end
  
    # Apply points from point_schedule, and adjust for team size
    def points_for(source_result)
      team_size = Result.count(:conditions => ["race_id =? and place = ?", source_result.race.id, source_result.place])
      points = point_schedule[source_result.members_only_place.to_i].to_f
      if points
        points / team_size
      else
        0
      end
    end
    
    def place_members_only?
      true
    end
    
    def create_standings
      root_standings = standings.create(:event => self)
      for category_name in [
        'Senior Men', 'Category 3 Men', 'Category 4/5 Men', 
        'Senior Women', 'Category 3 Women', 'Category 4 Women', 
        'Junior Men', 'Junior Women', 'Masters Men', 'Masters Women', 
        'Singlespeed/Fixed', 'Tandem']

        category = Category.find_or_create_by_name(category_name)
        root_standings.races.create(:category => category)
      end
    end
  
    # source_results must be in racer-order
    # TODO Probably should work with fully-populated Events instead
    def source_results(race)
      Result.find(:all,
                  :include => [:race, {:race => :category}, {:race => {:standings => :event}}],
                  :conditions => [%Q{members_only_place between 1 AND #{point_schedule.size - 1}
                    and events.type = 'SingleDayEvent' 
                    and categories.id in (#{category_ids_for(race)})
                    and (races.bar_points > 0 or (races.bar_points is null and standings.bar_points > 0))
                    and standings.date >= '#{date.year}-01-01' 
                    and standings.date <= '#{date.year}-12-31'}],
                  :order => 'racer_id'
      )
    end
    
    def member?(racer, date)
      racer && racer.member?(date)
    end
  end
end