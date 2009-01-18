#############################################################
#	Application
#############################################################

set :application, "radiant"
set :deploy_to, "/var/www/#{application}"

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
set :use_sudo, false

#############################################################
#	Servers
#############################################################

set :user, "root"
set :domain, "TARGET_SERVER"
server domain, :app, :web
role :db, domain, :primary => true
  
#############################################################
#	git
#############################################################

set :repository, 'git://github.com/radiant/radiant.git'
set :scm, :git
set :deploy_via, :copy
set :copy_cache, true
set :git_shallow_clone, 1

#############################################################
#	Passenger
#############################################################

namespace :passenger do
  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
    run "/etc/init.d/apache2 reload"
  end
end

after :deploy, "passenger:restart"

#############################################################
#	Radiant Deploy Tasks 
#############################################################

namespace :deploy do
  desc "Upload custom configuration files"
  task :upload_conf_files do
    put(File.read('config/deploy.rb'), "/var/www/radiant/current/config/deploy.rb", :mode => 0444)  
    put(File.read('config/database.yml'), "/var/www/radiant/current/config/database.yml", :mode => 0444)  
    put(File.read('config/radiant.vhost'), "/etc/apache2/sites-available/radiant", :mode => 0444)  
  end
  desc "Install gem dependencies"
  task :install_gems do
    run "gem install rspec rspec-rails --no-rdoc --no-ri"
  end
  desc "Create Passenger vhost symlink"
  task :symlink_vhost do
    run "ln -s /etc/apache2/sites-available/radiant /etc/apache2/sites-enabled/"
  end
  desc "Change owner to web user"
  task :chown_web do
    run "chown -R www-data.www-data /var/www/radiant"
  end
  desc "Create MySQL database"
  task :create_db do
    run "mysql -e \"create database radiant_production\""
  end
end



#############################################################
#	Database Rake Tasks
#############################################################

namespace :rake do
  desc "Show the available rake tasks."
  task :show_tasks do
    run("cd #{deploy_to}/current; /usr/bin/rake -T")
  end
  desc "Run the rake database bootstrap tasks"
  task :db_bootstrap do
    run("cd #{deploy_to}/current; /usr/bin/rake production db:bootstrap OVERWRITE=\"true\" ADMIN_NAME=\"Administrator\" ADMIN_USERNAME=\"admin\" ADMIN_PASSWORD=\"radiant\" DATABASE_TEMPLATE=\"styled-blog.yml\"")
  end
end
