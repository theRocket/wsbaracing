# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
# Toggle cache_classes to test caching
config.cache_classes = false
#config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Enable the breakpoint server that script/breakpointer connects to
config.breakpoint_server = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
# Toggle perform_caching to test caching
config.action_controller.perform_caching             = false
#config.action_controller.perform_caching             = true
config.action_view.cache_template_extensions         = true
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true
config.action_mailer.delivery_method = :test

APP_SERVER_ROOT = "http://localhost:3000"