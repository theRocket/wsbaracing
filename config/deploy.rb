require 'mongrel_cluster/recipes'

set :application, "obra"
set :repository, "svn+ssh://butlerpress.com/var/repos/#{application}"

role :app, "app.obra.org"

set :deploy_to, "/srv/www/rails/#{application}"


desc "OBRA custom deployment"
task :deploy do
  transaction do
    update_code
    symlink
    set_permissions
  end

  restart
end

desc "Set file permissions for Rails app"
task :set_permissions do
  sudo "chown -R wwwrun:rails #{deploy_to}/current/public"
  sudo "chown -R sw:rails #{deploy_to}/revisions.log"
  sudo "chmod +x /srv/www/rails/obra/current/public/dispatch.fcgi"
  sudo "chmod +x /srv/www/rails/obra/current/script/runner"
end

desc "Restart the web server"
task :restart, :roles => :app do
  restart_mongrel_cluster
end