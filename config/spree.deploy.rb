#############################################################
#	Application
#############################################################

set :application, "spree"
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

set :repository, 'git://github.com/schof/spree.git'
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
    put(File.read('config/deploy.rb'), "/var/www/spree/current/config/deploy.rb", :mode => 0444)  
    put(File.read('config/database.yml'), "/var/www/spree/current/config/database.yml", :mode => 0444)  
    put(File.read('config/spree.vhost'), "/etc/apache2/sites-available/spree", :mode => 0444)  
  end
  desc "Create Passenger vhost symlink"
  task :symlink_vhost do
    run "ln -s /etc/apache2/sites-available/spree /etc/apache2/sites-enabled/"
  end
  desc "Change owner to web user"
  task :chown_web do
    run "chown -R www-data.www-data /var/www"
  end
    desc "Install gems manually"
    task :gems_install do
      run "gem install --no-rdoc --no-ri has_many_polymorphs -v=2.12"
      run "gem install --no-rdoc --no-ri highline -v=1.4.0"
      run "gem install --no-rdoc --no-ri mini_magick"
      run "gem install --no-rdoc --no-ri activemerchant -v=1.3.2"
      run "gem install --no-rdoc --no-ri tlsmail"
      run "gem install --no-rdoc --no-ri active_presenter"
  end
  desc "Create MySQL database"
  task :create_db do
    run "mysql -e \"create database spree_production\""
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
  desc "Bootstrap the database (run the migrations, create admin account, load sample data.)"
  task :db_bootstrap do
    run("cd #{deploy_to}/current; /usr/bin/rake production AUTO_ACCEPT=Y db:bootstrap")
  end
end
