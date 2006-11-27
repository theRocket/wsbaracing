# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 4) do

  create_table "aliases", :force => true do |t|
    t.column "alias", :string
    t.column "name", :string
    t.column "racer_id", :integer
    t.column "team_id", :integer
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "aliases", ["name"], :name => "idx_name", :unique => true
  add_index "aliases", ["alias"], :name => "idx_id"
  add_index "aliases", ["racer_id"], :name => "idx_racer_id"
  add_index "aliases", ["team_id"], :name => "idx_team_id"

  create_table "aliases_disciplines", :id => false, :force => true do |t|
    t.column "discipline_id", :integer, :default => 0, :null => false
    t.column "alias", :string, :limit => 64, :null => false
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "aliases_disciplines", ["alias"], :name => "idx_alias"
  add_index "aliases_disciplines", ["discipline_id"], :name => "idx_discipline_id"

  create_table "categories", :force => true do |t|
    t.column "bar_category_id", :integer
    t.column "position", :integer, :default => 0, :null => false
    t.column "is_overall", :integer, :default => 0, :null => false
    t.column "name", :string, :limit => 64, :null => false
    t.column "overall_id", :integer
    t.column "scheme", :string, :default => ""
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "categories", ["name", "scheme"], :name => "idx_category_name_scheme", :unique => true
  add_index "categories", ["bar_category_id"], :name => "idx_bar_category_id"
  add_index "categories", ["overall_id"], :name => "idx_overall_id"

  create_table "discipline_bar_categories", :id => false, :force => true do |t|
    t.column "category_id", :integer, :default => 0, :null => false
    t.column "discipline_id", :integer, :default => 0, :null => false
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "discipline_bar_categories", ["category_id"], :name => "idx_category_id"
  add_index "discipline_bar_categories", ["discipline_id"], :name => "idx_discipline_id"

  create_table "disciplines", :force => true do |t|
    t.column "name", :string, :limit => 64, :null => false
    t.column "bar", :boolean
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "numbers", :boolean, :default => false
  end

  create_table "events", :force => true do |t|
    t.column "promoter_id", :integer
    t.column "parent_id", :integer
    t.column "city", :string, :limit => 128
    t.column "date", :date
    t.column "discipline", :string, :limit => 32
    t.column "flyer", :string
    t.column "name", :string
    t.column "notes", :string, :default => ""
    t.column "sanctioned_by", :string
    t.column "state", :string, :limit => 64
    t.column "type", :string, :limit => 32, :null => false
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "flyer_approved", :boolean, :default => false, :null => false
    t.column "cancelled", :boolean, :default => false
    t.column "oregon_cup_id", :integer
    t.column "notification", :boolean, :default => true
    t.column "number_issuer_id", :integer
  end

  add_index "events", ["date"], :name => "idx_date"
  add_index "events", ["discipline"], :name => "idx_disciplined"
  add_index "events", ["parent_id"], :name => "parent_id"
  add_index "events", ["promoter_id"], :name => "idx_promoter_id"
  add_index "events", ["type"], :name => "idx_type"
  add_index "events", ["oregon_cup_id"], :name => "oregon_cup_id"
  add_index "events", ["number_issuer_id"], :name => "events_number_issuer_id_index"

  create_table "mailing_lists", :force => true do |t|
    t.column "name", :string, :null => false
    t.column "friendly_name", :string, :null => false
    t.column "subject_line_prefix", :string, :null => false
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "description", :text
  end

  add_index "mailing_lists", ["name"], :name => "idx_name"

  create_table "number_issuers", :force => true do |t|
    t.column "name", :string, :null => false
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "number_issuers", ["name"], :name => "number_issuers_name_index", :unique => true

  create_table "posts", :force => true do |t|
    t.column "body", :text, :null => false
    t.column "date", :timestamp
    t.column "sender", :string, :null => false
    t.column "subject", :string, :null => false
    t.column "topica_message_id", :string
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "mailing_list_id", :integer, :default => 0, :null => false
  end

  add_index "posts", ["topica_message_id"], :name => "idx_topica_message_id", :unique => true
  add_index "posts", ["date"], :name => "idx_date"
  add_index "posts", ["sender"], :name => "idx_sender"
  add_index "posts", ["subject"], :name => "idx_subject"
  add_index "posts", ["mailing_list_id"], :name => "idx_mailing_list_id"
  add_index "posts", ["date", "mailing_list_id"], :name => "idx_date_list"

  create_table "promoters", :force => true do |t|
    t.column "email", :string
    t.column "name", :string, :default => ""
    t.column "phone", :string
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "promoters", ["name", "email", "phone"], :name => "promoter_info", :unique => true
  add_index "promoters", ["name"], :name => "idx_name"

  create_table "race_numbers", :force => true do |t|
    t.column "racer_id", :integer, :default => 0, :null => false
    t.column "discipline_id", :integer, :default => 0, :null => false
    t.column "number_issuer_id", :integer, :default => 0, :null => false
    t.column "value", :string, :null => false
    t.column "year", :integer, :default => 0, :null => false
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "race_numbers", ["racer_id"], :name => "racer_id"
  add_index "race_numbers", ["discipline_id"], :name => "discipline_id"
  add_index "race_numbers", ["number_issuer_id"], :name => "number_issuer_id"
  add_index "race_numbers", ["value"], :name => "race_numbers_value_index"

  create_table "racers", :force => true do |t|
    t.column "first_name", :string, :limit => 64
    t.column "last_name", :string
    t.column "member", :boolean, :default => true
    t.column "age", :integer
    t.column "city", :string, :limit => 128
    t.column "date_of_birth", :date
    t.column "license", :string, :limit => 64
    t.column "notes", :string
    t.column "state", :string, :limit => 64
    t.column "team_id", :integer
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "cell_fax", :string
    t.column "ccx_category", :string
    t.column "dh_category", :string
    t.column "email", :string
    t.column "gender", :string, :limit => 2
    t.column "home_phone", :string
    t.column "mtb_category", :string
    t.column "member_from", :date
    t.column "occupation", :string
    t.column "road_category", :string
    t.column "street", :string
    t.column "track_category", :string
    t.column "work_phone", :string
    t.column "zip", :string
  end

  add_index "racers", ["last_name"], :name => "idx_last_name"
  add_index "racers", ["first_name"], :name => "idx_first_name"
  add_index "racers", ["team_id"], :name => "idx_team_id"

  create_table "races", :force => true do |t|
    t.column "standings_id", :integer, :default => 0, :null => false
    t.column "category_id", :integer, :default => 0, :null => false
    t.column "city", :string, :limit => 128
    t.column "distance", :integer
    t.column "state", :string, :limit => 64
    t.column "field_size", :integer
    t.column "laps", :integer
    t.column "time", :float
    t.column "finishers", :integer
    t.column "notes", :string, :default => ""
    t.column "sanctioned_by", :string, :default => "OBRA"
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "result_columns", :string
    t.column "bar_points", :integer
  end

  add_index "races", ["category_id"], :name => "idx_category_id"
  add_index "races", ["standings_id"], :name => "idx_standings_id"

  create_table "results", :force => true do |t|
    t.column "category_id", :integer
    t.column "racer_id", :integer
    t.column "race_id", :integer, :default => 0, :null => false
    t.column "team_id", :integer
    t.column "age", :integer
    t.column "city", :string, :limit => 128
    t.column "date", :datetime
    t.column "date_of_birth", :datetime
    t.column "is_series", :boolean
    t.column "license", :string, :limit => 64, :default => ""
    t.column "notes", :string
    t.column "number", :string, :limit => 16, :default => ""
    t.column "place", :string, :limit => 8, :default => ""
    t.column "place_in_category", :integer, :default => 0
    t.column "points", :float, :default => 0.0
    t.column "points_from_place", :float, :default => 0.0
    t.column "points_bonus_penalty", :float, :default => 0.0
    t.column "points_total", :float, :default => 0.0
    t.column "state", :string, :limit => 64
    t.column "status", :string, :limit => 3
    t.column "time", :float
    t.column "time_bonus_penalty", :float
    t.column "time_gap_to_leader", :float
    t.column "time_gap_to_previous", :float
    t.column "time_gap_to_winner", :float
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "time_total", :float
    t.column "laps", :integer
  end

  add_index "results", ["category_id"], :name => "idx_category_id"
  add_index "results", ["race_id"], :name => "idx_race_id"
  add_index "results", ["racer_id"], :name => "idx_racer_id"
  add_index "results", ["team_id"], :name => "idx_team_id"

  create_table "scores", :force => true do |t|
    t.column "competition_result_id", :integer
    t.column "source_result_id", :integer
    t.column "points", :float
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "scores", ["competition_result_id"], :name => "scores_competition_result_id_index"
  add_index "scores", ["source_result_id"], :name => "scores_source_result_id_index"

  create_table "standings", :force => true do |t|
    t.column "event_id", :integer, :default => 0, :null => false
    t.column "bar_points", :integer, :default => 1
    t.column "date", :datetime
    t.column "name", :string
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "ironman", :boolean, :default => true
    t.column "position", :integer, :default => 0
    t.column "discipline", :string, :limit => 32
    t.column "notes", :string, :default => ""
    t.column "source_id", :integer
    t.column "type", :string, :limit => 32
  end

  add_index "standings", ["date"], :name => "idx_date"
  add_index "standings", ["event_id"], :name => "event_id"
  add_index "standings", ["source_id"], :name => "source_id"

  create_table "teams", :force => true do |t|
    t.column "name", :string, :null => false
    t.column "city", :string, :limit => 128
    t.column "state", :string, :limit => 64
    t.column "notes", :string
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "member", :boolean, :default => false
  end

  add_index "teams", ["name"], :name => "idx_name", :unique => true

  create_table "users", :force => true do |t|
    t.column "name", :string, :null => false
    t.column "username", :string, :null => false
    t.column "password", :string, :null => false
    t.column "lock_version", :integer, :default => 0, :null => false
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
  end

  add_index "users", ["username"], :name => "idx_alias", :unique => true

  add_foreign_key "aliases", ["racer_id"], "racers", ["id"], :on_delete => :cascade
  add_foreign_key "aliases", ["team_id"], "teams", ["id"], :on_delete => :cascade

  add_foreign_key "aliases_disciplines", ["discipline_id"], "disciplines", ["id"], :on_delete => :cascade

  add_foreign_key "categories", ["bar_category_id"], "categories", ["id"], :on_delete => :set_null
  add_foreign_key "categories", ["overall_id"], "categories", ["id"], :on_delete => :set_null

  add_foreign_key "discipline_bar_categories", ["category_id"], "categories", ["id"], :on_delete => :cascade
  add_foreign_key "discipline_bar_categories", ["discipline_id"], "disciplines", ["id"], :on_delete => :cascade

  add_foreign_key "events", ["number_issuer_id"], "number_issuers", ["id"]
  add_foreign_key "events", ["parent_id"], "events", ["id"], :on_delete => :cascade
  add_foreign_key "events", ["promoter_id"], "promoters", ["id"], :on_delete => :set_null
  add_foreign_key "events", ["oregon_cup_id"], "events", ["id"], :on_delete => :set_null
  add_foreign_key "events", ["number_issuer_id"], "number_issuers", ["id"]

  add_foreign_key "posts", ["mailing_list_id"], "mailing_lists", ["id"]

  add_foreign_key "race_numbers", ["racer_id"], "racers", ["id"], :on_delete => :cascade
  add_foreign_key "race_numbers", ["discipline_id"], "disciplines", ["id"]
  add_foreign_key "race_numbers", ["number_issuer_id"], "number_issuers", ["id"]

  add_foreign_key "racers", ["team_id"], "teams", ["id"]

  add_foreign_key "races", ["category_id"], "categories", ["id"]
  add_foreign_key "races", ["standings_id"], "standings", ["id"], :on_delete => :cascade

  add_foreign_key "results", ["category_id"], "categories", ["id"]
  add_foreign_key "results", ["race_id"], "races", ["id"], :on_delete => :cascade
  add_foreign_key "results", ["racer_id"], "racers", ["id"]
  add_foreign_key "results", ["team_id"], "teams", ["id"]

  add_foreign_key "scores", ["competition_result_id"], "results", ["id"], :on_delete => :cascade
  add_foreign_key "scores", ["source_result_id"], "results", ["id"], :on_delete => :cascade

  add_foreign_key "standings", ["event_id"], "events", ["id"], :on_delete => :cascade
  add_foreign_key "standings", ["source_id"], "standings", ["id"], :on_delete => :cascade
  add_foreign_key "standings", ["source_id"], "standings", ["id"], :on_delete => :cascade

end
