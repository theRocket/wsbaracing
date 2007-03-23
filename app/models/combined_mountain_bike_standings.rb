# OBRA combines Pro, Semi-Pro, Elite Men and Pro, Elite, Expert Women into two sets of combined standings.
# The combined standings are used for the BAR. Combined results are placed by time. Results without times 
# are placed last in non-determinate order. (They should be placed by category and place)
class CombinedMountainBikeStandings < CombinedStandings

  def discipline
    'Mountain Bike'
  end
  
  # Recreate combine results from source results. Also set source race BAR points to none
  def recalculate
    logger.debug("CombinedMountainBikeStandings recalculate")
    create_races if races(true).empty?
    for race in races
      race.results.clear unless race.results.empty?
      combined_results = []

      for source_race in source.races(true)
        if race.category.include?(source_race.category)
          combined_results = combined_results + source_race.results
          source_race.update_attribute(:bar_points , 0)
        end
      end
      
      if !combined_results.empty? and combined_results.first.time and combined_results.first.time > 0
        combined_results.delete_if {|result| result.time.nil? or result.time <= 0}
        # TODO Move to Result
        combined_results = combined_results.sort {|x, y| 
          if x.time.nil?
            1
          else
            x.time <=> y.time
          end
        }
      else
        # Sort by place, not time
        # Should consider category, too
        combined_results = combined_results.sort
      end
      combined_results.delete_if {|result| result.place.to_i == 0}
      combined_results.each_with_index {|result, i|
        race.results.create(:place => (i + 1), :racer => result.racer, :team => result.team, :time => result.time)
      }
    end
  end

  def create_races
    races.create(:category => men_combined)
    races.create(:category => women_combined)
  end
  
  def men_combined
    unless defined? @@men_combined
      @@men_combined = Category.find_or_create_by_name('Pro, Semi-Pro, Elite Men')
      @@men_combined.competition_categories.create_unless_exists(:source_category => Category.find_or_create_by_name('Pro Men'))
      @@men_combined.competition_categories.create_unless_exists(:source_category => Category.find_or_create_by_name('Semi-Pro Men'))
      @@men_combined.competition_categories.create_unless_exists(:source_category => Category.find_or_create_by_name('Elite Men'))
    end
    @@men_combined
  end
  
  def women_combined
    unless defined? @@women_combined
      @@women_combined = Category.find_or_create_by_name('Pro, Elite, Expert Women')
      @@women_combined.competition_categories.create_unless_exists(:source_category => Category.find_or_create_by_name('Pro Women'))
      @@women_combined.competition_categories.create_unless_exists(:source_category => Category.find_or_create_by_name('Elite Women'))
      @@women_combined.competition_categories.create_unless_exists(:source_category => Category.find_or_create_by_name('Expert Women'))
    end
    @@women_combined
  end
  
  def to_s
    "<CombinedStandings id '#{id}' event_id '#{self[:event_id]}' source_id '#{self[:source_id]}' '#{name}'>"
  end
end