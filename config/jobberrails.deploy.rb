#############################################################
#	Application
#############################################################

set :application, "jobberrails"
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

set :repository, 'git://github.com/jcnetdev/jobberrails.git'
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
#	Spree Deploy Tasks 
#############################################################

namespace :deploy do
  desc "Upload custom configuration files"
  task :upload_conf_files do
    put(File.read('config/deploy.rb'), "/var/www/jobberrails/current/config/deploy.rb", :mode => 0444)  
    put(File.read('config/database.yml'), "/var/www/jobberrails/current/config/database.yml", :mode => 0444)  
    put(File.read('config/jobberrails.vhost'), "/etc/apache2/sites-available/jobberrails", :mode => 0444)  
  end
  desc "Create Passenger vhost symlink"
  task :symlink_vhost do
    run "ln -s /etc/apache2/sites-available/jobberrails /etc/apache2/sites-enabled/"
  end
  desc "Change owner to web user"
  task :chown_web do
    run "chown -R www-data.www-data /var/www"
  end
  desc "Install Rails version 2.1.0"
  task :rails_install do
    run("cd #{deploy_to}/current; /usr/bin/gem install rails -v 2.1.0 --no-rdoc --no-ri")
  end
  desc "Install haml gem"
  task :haml_install do
    run("cd #{deploy_to}/current; /usr/bin/gem install haml --no-rdoc --no-ri")
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
  task :gems_install do
    run("cd #{deploy_to}/current; /usr/bin/rake gems:install --no-rdoc --no-ri")
  end
  task :db_create do
    run("cd #{deploy_to}/current; /usr/bin/rake db:create RAILS_ENV=production")
  end
  task :db_schema_load do
    run("cd #{deploy_to}/current; /usr/bin/rake db:schema:load RAILS_ENV=production")
  end
  task :db_migrate do
    run("cd #{deploy_to}/current; /usr/bin/rake db:migrate RAILS_ENV=production")
  end
end
