# Road, track, criterium, time trial ...
class Discipline < ActiveRecord::Base

  has_and_belongs_to_many :bar_categories, :class_name => "Category", :join_table => "discipline_bar_categories"

  NONE = Discipline.new(:name => "", :id => nil).freeze unless defined?(NONE)
  @@aliases = nil
  
  # Look up Discipline by name or alias. Caches Disciplines in memory
  def Discipline.[](name)
    return nil unless name
    load_aliases unless @@aliases
    if name.is_a?(Symbol)
      @@aliases[name]
    else
      return nil if name.blank?
      @@aliases[name.underscore.gsub(' ', '_').to_sym]
    end
  end

  def Discipline.find_all_bar
    Discipline.find_all("bar = true")
  end

  def Discipline.find_via_alias(name)
    Discipline[name]
  end
  
  # All Disciplines that are used for numbers. Configured in the database.
  def Discipline.find_for_numbers
    Discipline.find(:all, :conditions => 'numbers=true')
  end

  def Discipline.load_aliases
    @@aliases = {}
    results = connection.select_all(
      "SELECT discipline_id, alias FROM aliases_disciplines"
    )
    for result in results
      @@aliases[result["alias"].underscore.gsub(' ', '_').to_sym] = Discipline.find(result["discipline_id"].to_i)
    end
    for discipline in Discipline.find_all
      @@aliases[discipline.name.gsub(' ', '_').underscore.to_sym] = discipline
    end
  end
  
  # Clear out cached aliases
  def Discipline.reset
    @@aliases = nil
  end
  
  def Discipline.find_all_names
    [''] + Discipline.find_all.collect {|discipline| discipline.name}
  end
  
  def to_param
    @param || @param = name.underscore.gsub(' ', '_')
  end

  def <=>(other)
    name <=> other.name
  end  

  def to_s
    "<#{self.class} #{id} #{name}>"
  end
end