module Competitions
  class AgeGradedBar < Competition

    CATEGORIES = []

    def points_for(scoring_result)
      scoring_result.points
    end

    def source_results(race)
      # Need date of birth range
      # Need category map from Masters Men to Masters Men 30-34, etc.
      # start_date_of_birth = last day of year prior to event year
      # end_date_of_birth = last day of event year
      Result.find(:all,
                  :include => [:race, {:racer => :team}, :team, {:race => [{:standings => :event}, :category]}],
                  :conditions => [%Q{events.type = 'OverallBar' 
                    and categories.id = #{race.category.parent(true).id}
                    and racers.date_of_birth between '#{race.dates_of_birth.begin}' and '#{race.dates_of_birth.end}'
                    and events.date >= '#{date.year}-01-01' 
                    and events.date <= '#{date.year}-12-31'}],
                  :order => 'racer_id'
      )
    end
    
    def create_standings
      root_standings = standings.create(:event => self)
      for category in create_categories
        root_standings.races.create!(:category => category)
      end
    end
    
    def create_categories
      if CATEGORIES.empty?
        30.step(65, 5) do |age|
          CATEGORIES << Category.new(:name => "Masters Men #{age}-#{age + 4}", :ages => (age)..(age + 4), :parent => Category.new(:name => 'Masters Men'))
        end
        CATEGORIES << Category.new(:name => 'Masters Men 70+', :ages => 70..999, :parent => Category.new(:name => 'Masters Men'))
        
        30.step(55, 5) do |age|
          CATEGORIES << Category.new(:name => "Masters Women #{age}-#{age + 4}", :ages => (age)..(age + 4), :parent => Category.new(:name => 'Masters Women'))
        end
        CATEGORIES << Category.new(:name => 'Masters Women 60+', :ages => 60..999, :parent => Category.new(:name => 'Masters Women'))
        
        CATEGORIES << Category.new(:name => "Junior Men 10-12", :ages => 10..12, :parent => Category.new(:name => 'Junior Men'))
        CATEGORIES << Category.new(:name => "Junior Men 13-14", :ages => 13..14, :parent => Category.new(:name => 'Junior Men'))
        CATEGORIES << Category.new(:name => "Junior Men 15-16", :ages => 15..16, :parent => Category.new(:name => 'Junior Men'))
        CATEGORIES << Category.new(:name => "Junior Men 17-18", :ages => 17..18, :parent => Category.new(:name => 'Junior Men'))
        
        CATEGORIES << Category.new(:name => "Junior Women 10-12", :ages => 10..12, :parent => Category.new(:name => 'Junior Women'))
        CATEGORIES << Category.new(:name => "Junior Women 13-14", :ages => 13..14, :parent => Category.new(:name => 'Junior Women'))
        CATEGORIES << Category.new(:name => "Junior Women 15-16", :ages => 15..16, :parent => Category.new(:name => 'Junior Women'))
        CATEGORIES << Category.new(:name => "Junior Women 17-18", :ages => 17..18, :parent => Category.new(:name => 'Junior Women'))

        for category in CATEGORIES
          if Category.exists?(:name => category.parent.name)
            category.parent = Category.find_by_name(category.parent.name)
          else
            category.parent.save!
          end
          
          existing_category = Category.find_by_name(category.name)
          if existing_category.nil?
            category.save!
          elsif existing_category.ages != category.ages || existing_category.parent != category.parent
            existing_category.ages = category.ages
            existing_category.parent = category.parent
            existing_category.save!
          end          
        end
      end
      CATEGORIES
    end

    def friendly_name
      'Age Graded BAR'
    end
  end
end