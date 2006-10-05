class CombinedMountainBikeStandings < CombinedStandings

  def discipline
    'Mountain Bike'
  end
  
  def recalculate
    logger.debug("CombinedMountainBikeStandings Recalculate")
    create_races if races(true).empty?
    for race in races
      race.results.clear unless race.results.empty?
      combined_results = []

      for source_race in source.races(true)
        if source_race.bar_category == race.category
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
        race.results.create!(:place => (i + 1), :racer => result.racer, :team => result.team, :time => result.time)
      }
    end
  end

  def create_races
    races.create!(:category => Category.find_bar('Pro, Semi-Pro, Elite Men'))
    races.create!(:category => Category.find_bar('Pro, Elite, Expert Women'))
  end
  
  def to_s
    "<CombinedStandings id '#{id}' event_id '#{self[:event_id]}' source_id '#{self[:source_id]}' '#{name}'>"
  end
end