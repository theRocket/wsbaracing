Project.configure do |project|
  project.email_notifier.emails = ['scott@butlerpress.com']
  project.build_command = "./script/cruise_build.rb #{project.name}"
end
