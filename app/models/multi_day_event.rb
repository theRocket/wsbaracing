# Event that spans more than one day: stage races, six days, omniums
# MultiDayEvents represent events that occur on concurrent days, and Series and 
# WeeklySeries subclasses represent events that do not occur on concurrent days, though
# this is just a convention.
#
# Calculate start_date, end_date, and date from events. 
# date = start_date
#
# Cannot have a parent event
#
# By convention, only SingleDayEvents have Standings and Results -- MultiDayEvents do not. 
# Final standings like Overall GC are associated with the last day's SingleDayEvent.
#
# Building large object trees of events and children and memory may not work correctly.
# Prefer +create+ over +new+ and +build+
#
# TODO Build new child event should populate child event with parent data
class MultiDayEvent < Event

  PROPOGATED_ATTRIBUTES = ['cancelled', "city", "discipline", "flyer", "flyer_approved", "name", "promoter_id", "sanctioned_by", "state"] unless defined?(PROPOGATED_ATTRIBUTES)

  validates_presence_of :name, :date
  validate_on_create {:parent.nil?}
  validate_on_update {:parent.nil?}
  
  before_save :update_date
  
  has_many :events, 
           :class_name => 'SingleDayEvent',
           :foreign_key => "parent_id",
           :order => "date" do
             def create!(attributes = {})
               attributes[:parent_id] = @owner.id
               attributes[:parent] = @owner
               event = SingleDayEvent.new(attributes)
               event.parent = @owner
               event.save!
               event
             end

             def create(attributes = {})
               attributes[:parent_id] = @owner.id
               attributes[:parent] = @owner
               event = SingleDayEvent.new(attributes)
               event.parent = @owner
               event.save
               event
             end
           end

  def MultiDayEvent.find_all_by_year(year)
    # Workaround Rails class loader behavior
    WeeklySeries
    start_of_year = Date.new(year, 1, 1)
    end_of_year = Date.new(year, 12, 31)
    return MultiDayEvent.find(
      :all,
      :conditions => ["date >= ? and date <= ? and type = ?", start_of_year, end_of_year, "MultiDayEvent"],
      :order => "date"
    )
  end

  # Create MultiDayEvent from several SingleDayEvents.
  # Use first SingleDayEvent to populate date, name, promoter, etc.
  # Guess subclass (MultiDayEvent, Series, WeeklySeries) from SingleDayEvent dates
  def MultiDayEvent.create_from_events(events)
    if events.empty?
      raise ArgumentError.new("events cannot be empty")
    end
    
    first_event = events.first
    new_event_attributes = {
      :city => first_event.city,
      :discipline => first_event.discipline,
      :flyer => first_event.flyer,
      :name => first_event.name,
      :promoter => first_event.promoter,
      :sanctioned_by => first_event.sanctioned_by,
      :state => first_event.state
    }
    
    new_multi_day_event_class = MultiDayEvent.guess_type(events)
    multi_day_event = new_multi_day_event_class.create!(new_event_attributes)

    for event in events
      event.parent = multi_day_event
      event.save!
    end

    multi_day_event.events(true)
    multi_day_event
  end
  
  def MultiDayEvent.guess_type(name, date)
    events = SingleDayEvent.find(:all, :conditions => ['name = ? and extract(year from date) = ?', name, date])
    MultiDayEvent.guess_type(events)
  end
  
  def MultiDayEvent.guess_type(events)
    length = events.last.date - events.first.date
    if events.size - 1 == length
     MultiDayEvent
    else
      if events.first.date.wday == 0 or events.first.date.wday == 6
        Series
      else
        WeeklySeries
      end
    end
  end
  
  def MultiDayEvent.same_name_and_year(event)
    MultiDayEvent.find(:first, :conditions => ['name = ? and extract(year from date) = ?', event.name, event.date.year])
  end
  
  def initialize(attributes = nil)
    super
    self.date = Time.new.beginning_of_year unless self[:date]
  end
  
  # Update child events from parents' attributes if child attribute has the
  # same value as the parent before update
  def update_events(original_event_attributes)
    for attribute in PROPOGATED_ATTRIBUTES
      original_value = original_event_attributes[attribute]
      new_value = self[attribute]
      RACING_ON_RAILS_DEFAULT_LOGGER.debug("#{attribute}, #{original_value}, #{new_value}")
      if original_value.nil?
        SingleDayEvent.update_all(
          ["#{attribute}=?", new_value], 
          ["#{attribute} is null and parent_id=?", self[:id]]
        ) unless original_value == new_value
      else
        SingleDayEvent.update_all(
          ["#{attribute}=?", new_value], 
          ["#{attribute}=? and parent_id=?", original_value, self[:id]]
        ) unless original_value == new_value
      end
    end
  end
  
  def after_child_event_save
    update_date
  end
  
  def after_child_event_destroy
    update_date
  end
  
  # Uses SQL query to set +date+ from child events
  def update_date
    return if new_record?
    
    minimum_date = MultiDayEvent.connection.select_value("select min(date) from events where parent_id = #{id}")
    unless minimum_date.blank? || minimum_date == self.date.to_s
      MultiDayEvent.connection.execute("update events set date = '#{minimum_date}' where id = #{id}")
      self.date = minimum_date
    end
  end

  # +date+
  def start_date
    date
  end
  
  def end_date
    if !events(true).empty?
      events.last.date
    else
      start_date
    end
  end
  
  def end_date_s
    "#{end_date.month}/#{end_date.day}"
  end
  
  def date_range_s
    start_date_s = "#{start_date.month}/#{start_date.day}"
    if start_date == end_date
    	start_date_s
    elsif start_date.month == end_date.month
      "#{start_date_s}-#{end_date.day}"
    else
      "#{start_date_s}-#{end_date.month}/#{end_date.day}"
    end
  end
  
  def date_range_long_s
    start_date_s = start_date.strftime('%a, %B %d')
    if start_date == end_date
    	start_date_s
    else
      "#{start_date_s} to #{end_date.strftime('%a, %B %d')}"
    end
  end
  
  def to_s
    "<#{self.class} #{id} #{discipline} #{name} #{date} #{events.size}>"
  end
  
  def friendly_class_name
    "Multi-Day Event"
  end
end