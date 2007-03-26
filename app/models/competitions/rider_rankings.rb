module Competitions
  
  # WSBA rider rankings. Riders get points for top-10 finishes in any event
  class RiderRankings < Competition
    # FIXME Need to exclude non-members from the standings
    
    def friendly_name
      'Rider Rankings'
    end

    def point_schedule
      [0, 100, 70, 50, 40, 36, 32, 28, 24, 20, 16]
    end
  
    # Apply points from point_schedule, and adjust for team size
    def points_for(source_result)
      team_size = Result.count(:conditions => ["race_id =? and place = ?", source_result.race.id, source_result.place])
      points = point_schedule[source_result.place.to_i].to_f
      if points
        points / team_size
      else
        0
      end
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
    def source_results(race)
      Result.find_by_sql(
        %Q{SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
            LEFT OUTER JOIN races ON races.id = results.race_id 
            LEFT OUTER JOIN standings ON races.standings_id = standings.id 
            LEFT OUTER JOIN events ON standings.event_id = events.id 
            LEFT OUTER JOIN categories ON races.category_id = categories.id 
              WHERE (place between 1 AND #{point_schedule.size - 1}
                and events.type = 'SingleDayEvent' 
                and categories.id in (#{category_ids_for(race)})
                and (races.bar_points > 0 or (races.bar_points is null and standings.bar_points > 0))
                and standings.date >= '#{date.year}-01-01' 
                and standings.date <= '#{date.year}-12-31') 
            order by racer_id}
      )
    end
    
    def member?(racer, date)
      racer && racer.member?(date)
    end
  end
end