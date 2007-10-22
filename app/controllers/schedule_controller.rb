# Controller for schedule/calendar in different formats. Default to current year if not provided.
#
# Caches all of its pages
class ScheduleController < ApplicationController

    session :off
    caches_page :index, :list

    # Default calendar format
    # === Params
    # * year: default to current year
    # === Assigns
    # * year
    # * schedule: instance of year's Schedule::Schedule
    def index
      @year = params["year"].to_i
      @year = Date.today.year if @year == 0
      events = SingleDayEvent.find_all_by_year(@year)
      @schedule = Schedule::Schedule.new(@year, events)
    end

    # List of events -- one line per event
    # === Params
    # * year: default to current year
    # === Assigns
    # * year
    # * schedule: instance of year's Schedule::Schedule
    def list
      @year = params["year"].to_i
      @year = Date.today.year if @year == 0
      events = SingleDayEvent.find_all_by_year(@year)
      @schedule = Schedule::Schedule.new(@year, events)
    end
end