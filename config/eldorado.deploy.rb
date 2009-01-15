#############################################################
#	Application
#############################################################

set :application, "eldorado"
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

set :repository, 'git://github.com/trevorturk/el-dorado.git'
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
  end
end

after :deploy, "passenger:restart"

#############################################################
#	Additional Passenger Deploy Tasks
#############################################################

namespace :deploy do
  desc "Upload custom configuration files"
  task :upload_configs do
    put(File.read('config/deploy.rb'), "#{release_path}/config/deploy.rb", :mode => 0444)  
    put(File.read('config/database.yml'), "#{release_path}/config/database.yml", :mode => 0444)  
    put(File.read('config/eldorado.vhost'), "/etc/apache2/sites-available/eldorado", :mode => 0444)  
  end
  
  desc "Create Passenger vhost sym link"
  task :apache_symlink do
    run "ln -s /etc/apache2/sites-available/eldorado /etc/apache2/sites-enabled/"
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
  