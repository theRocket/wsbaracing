# TODO Should this be in database as full-fledged ActiveRecord?
# bar_point_schedule should be stored in the database with the BAR?
class RacingAssociation

  attr_accessor :name, :gender_specific_numbers, :rental_numbers, :short_name, :show_license, :state
  attr_accessor :show_only_association_sanctioned_races_on_calendar
  
  def initialize
    @show_license = true
  end

  def gender_specific_numbers?
    @gender_specific_numbers
  end
  
  def to_s
    "#<RacingAssociation #{short_name} #{name}>"
  end
end
