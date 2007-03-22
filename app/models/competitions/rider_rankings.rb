module Competitions
  
  # WSBA rider rankings. Riders get points for top-10 finishes in any event
  class RiderRankings < Competition
    def friendly_name
      'Rider Rankings'
    end

    def points_schedule
      [0, 100, 70, 50, 40, 36, 32, 28, 24, 20, 16]
    end
    
    def create_standings
      root_standings = standings.create(:event => self)
      for category_name in [
        'Senior Men', 'Category 3 Men', 'Category 4/5 Men', 
        'Senior Women', 'Category 3 Women', 'Category 4 Women', 
        'Junior Men', 'Junior Women', 'Masters Men', 'Masters Women', 
        'Singlespeed/Fixed', 'Tandem']

        category = Category.find_or_create_by_name_and_scheme(category_name, ASSOCIATION.short_name)
        root_standings.races.create(:category => category)
        competition_categories.create_unless_exists(:category => category)
      end

      category = Category.find_or_create_by_name_and_scheme('Senior Men', ASSOCIATION.short_name)
      source_category = Category.find_or_create_by_name_and_scheme('Men A', ASSOCIATION.short_name)
      CompetitionCategory.create_unless_exists(:category => category, :source_category => source_category)

      source_category = Category.find_or_create_by_name_and_scheme('Senior Men Pro 1/2', ASSOCIATION.short_name)
      CompetitionCategory.create_unless_exists(:category => category, :source_category => source_category)

      category = Category.find_or_create_by_name_and_scheme('Senior Women', ASSOCIATION.short_name)
      source_category = Category.find_or_create_by_name_and_scheme('Senior Women 1/2/3', ASSOCIATION.short_name)
      CompetitionCategory.create_unless_exists(:category => category, :source_category => source_category)

      category = Category.find_or_create_by_name_and_scheme('Masters Women', ASSOCIATION.short_name)
      source_category = Category.find_or_create_by_name_and_scheme('Masters 35+ Women', ASSOCIATION.short_name)
      CompetitionCategory.create_unless_exists(:category => category, :source_category => source_category)
    end
  
    # source_results must be in racer-order
    def source_results(race)
      Result.find_by_sql(
        %Q{SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
            LEFT OUTER JOIN races ON races.id = results.race_id 
            LEFT OUTER JOIN standings ON races.standings_id = standings.id 
            LEFT OUTER JOIN events ON standings.event_id = events.id 
            LEFT OUTER JOIN categories ON races.category_id = categories.id 
              WHERE (place between 1 AND #{points_schedule.size - 1}
                and events.type = 'SingleDayEvent' 
                and categories.id in (#{race.competition_category_ids.join(', ')})
                and (races.bar_points > 0 or (races.bar_points is null and standings.bar_points > 0))
                and standings.date >= '#{date.year}-01-01' 
                and standings.date <= '#{date.year}-12-31') 
            order by racer_id}
      )
    end
  end
end