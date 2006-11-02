class UpcomingEvents
  
  attr_reader :events, :weekly_series
  
  def initialize(date = Date.today, weeks = 2)
    date = date || Date.today
    weeks = weeks || 2
    _events = SingleDayEvent.find(
      :all, 
      :conditions => ['date >= ? and date <= ? and sanctioned_by = ? and cancelled = ? and parent_id is null', 
                      date.to_time.beginning_of_day, cutoff_date(date, weeks), ASSOCIATION.short_name, false],
      :order => 'date')

    _events.concat(MultiDayEvent.find(
        :all, 
        :include => :events,
        :conditions => ['events_events.date >= ? and events_events.date <= ? and events.sanctioned_by = ? and events.type = ?', 
                        date.to_time.beginning_of_day, cutoff_date(date, weeks), ASSOCIATION.short_name, 'MultiDayEvent'],
        :order => 'events.date'))

    series_events = (SingleDayEvent.find(
        :all, 
        :include => :parent,
        :conditions => ['events.date >= ? and events.date <= ? and events.sanctioned_by = ? and events.cancelled = ? and events.parent_id is not null', 
            date.to_time.beginning_of_day, cutoff_date(date, weeks), ASSOCIATION.short_name, false],
        :order => 'events.date'))
    # Cannot apply condition  with Rails' generated SQL
    _events.concat(series_events.select {|event| event.parent.is_a?(Series) and !event.parent.is_a?(WeeklySeries)})
    
    weekly_series_events = SingleDayEvent.find(
      :all, 
      :include => :parent,
      :conditions => [
        'events.date >= ? and events.date <= ? and events.sanctioned_by = ? and events.cancelled = ? and events.parent_id is not null', 
                      date.to_time.beginning_of_day, cutoff_date(date, weeks), ASSOCIATION.short_name, false],
      :order => 'events.date')
      # Cannot apply condition  with Rails' generated SQL
      weekly_series_events.reject! {|event| !event.parent.is_a?(WeeklySeries)}
    
    for event in weekly_series_events
      event.parent.days_of_week << event.date
    end
    @events = Hash.new
    @weekly_series = Hash.new
    unique_weekly_series = weekly_series_events.collect {|event| event.parent}.to_set
    
    for discipline in ['Road', 'Mountain Bike', 'Track', 'Cyclocross']
      @events[discipline] = []
      @weekly_series[discipline] = []
    end

    for event in _events
      case event.discipline
      when 'Mountain Bike'
        @events['Mountain Bike'] << event
      when 'Track'
        @events['Track'] << event
      when'Cyclocross'
        @events['Cyclocross'] << event
      else
        @events['Road'] << event
      end
    end

    for event in unique_weekly_series
      case event.discipline
      when 'Mountain Bike'
        @weekly_series['Mountain Bike'] << event
      when 'Track'
        @weekly_series['Track'] << event
      when'Cyclocross'
        @weekly_series['Cyclocross'] << event
      else
        @weekly_series['Road'] << event
      end
    end
  end
    
  def cutoff_date(date, weeks)
    case date.wday
    when 0
      date + (weeks.to_i * 7)
    when 1
      date + (weeks.to_i * 7) - 1
    when 2
      date + (weeks.to_i * 7) - 2
    when 3
      date + (weeks.to_i * 7) - 3
    when 4
      date + (weeks.to_i * 7) - 4
    when 5
      date + (weeks.to_i * 7) - 5
    when 6
      date + (weeks.to_i * 7) + 1
    end
  end
end