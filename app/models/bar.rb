require 'fileutils'

# Best All-around Rider Competition. Assigns points for each top-15 placing in major Disciplines: road, track, etc.
# Calculates a BAR for each Discipline, and an Overall BAR that combines all the discipline BARs.
# Also calculates a team BAR.
# Recalculating the BAR at years-end can take nearly 30 minutes even on a fast server. Recalculation must be manually triggered.
# This class implements a number of OBRA-specific rules and should be generalized and simplified.
# The BAR categories and disciplines are all configured in the databsase. Race categories need to have a bar_category_id to 
# show up in the BAR; disciplines must exist in the disciplines table and discipline_bar_categories.
class Bar < Competition
  include FileUtils

  # TODO Add add_child(...) to Race
  # check placings for ties
  # remove one-day licensees
  
  validate :valid_dates
  # TODO Move to BarHelper
  POINTS_AND_LABELS = [['None', 0], ['Normal', 1], ['Double', 2], ['Triple', 3]] unless defined?(POINTS_AND_LABELS)
  
  # Expire BAR web pages from cache. Expires *all* BAR pages. Shouldn't be in the model, either
  # BarSweeper seems to fire, but does not expire pages?
  def Bar.expire_cache
    FileUtils::rm_rf("#{RAILS_ROOT}/public/bar.html")
    FileUtils::rm_rf("#{RAILS_ROOT}/public/bar")
  end

  def point_schedule
    [0, 30, 25, 22, 19, 17, 15, 13, 11, 9, 7, 5, 4, 3, 2, 1]
  end

  # Source result = counts towards the BAR "race" and BAR results
  # Example: Piece of Cake RR, 6th, Jon Knowlson
  #
  # bar_result, bar_race = BAR itself and placing in the BAR
  # Example: Senior Men BAR, 130th, Jon Knowlson, 45 points
  #
  # BAR results add scoring results as scores
  # Example: 
  # Senior Men BAR, 130th, Jon Knowlson, 18 points
  #  - Piece of Cake RR, 6th, Jon Knowlson 10 points
  #  - Silverton RR, 8th, Jon Knowlson 8 points
  def source_results(race)
    competition_category_ids = race.competition_category_ids
    if competition_category_ids.empty?
      logger.warn("BAR race #{race.name} competition_category_ids are empty")
      return []
    end
    
    race_discipline = race.standings.discipline
    Result.find_by_sql(
      %Q{SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
          LEFT OUTER JOIN races ON races.id = results.race_id 
          LEFT OUTER JOIN standings ON races.standings_id = standings.id 
          LEFT OUTER JOIN events ON standings.event_id = events.id 
          LEFT OUTER JOIN categories ON races.category_id = categories.id 
            WHERE (categories.id in (#{competition_category_ids.join(', ')})
              and place between 1 AND #{point_schedule.size - 1}
              and (standings.discipline = '#{race_discipline}' or (standings.discipline is null and events.discipline = '#{race_discipline}'))
              and events.type = 'SingleDayEvent' 
              and (races.bar_points > 0 or (races.bar_points is null and standings.bar_points > 0))
              and standings.date >= '#{date.year}-01-01' 
              and standings.date <= '#{date.year}-12-31') 
          order by racer_id}
    )
    # Might need to remove Competitions
  end

  def expire_cache
    Bar.expire_cache
  end
  
  # Apply points from point_schedule, and adjust for field size
  def points_for(scoring_result)
    field_size = scoring_result.race.field_size
    
    team_size = Result.count(:conditions => ["race_id =? and place = ?", scoring_result.race.id, scoring_result.place])
    points = point_schedule[scoring_result.place.to_i] * scoring_result.race.bar_points / team_size
    if scoring_result.race.standings.name['CoMotion'] and scoring_result.race.category.name == 'Category C Tandem'
      points = points / 2.0
    end
    if scoring_result.race.bar_points == 1 and field_size >= 75
      points = points * 1.5
    end
    points
  end
  
  def create_standings
    raise errors.full_messages unless errors.empty?
    for discipline in Discipline.find_all_bar
      discipline_standings = standings.create(
        :name => discipline.name,
        :discipline => discipline.name
      )
      raise(RuntimeError, discipline_standings.errors.full_messages) unless discipline_standings.errors.empty?
      for category in discipline.bar_categories
        race = discipline_standings.races.create(:category => category)
        raise(RuntimeError, race.errors.full_messages) unless race.errors.empty?
      end
    end
  end

  def friendly_name
    'BAR'
  end

  def to_s
    "#<Bar #{id} #{discipline} #{name} #{date}>"
  end
end
