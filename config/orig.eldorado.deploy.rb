load 'deploy' if respond_to?(:namespace) # cap2 differentiator

set :repository, 'git://github.com/trevorturk/el-dorado.git'
set :scm, :git
set :deploy_via, :copy
set :copy_cache, true
set :git_shallow_clone, 1

set :application, 'eldorado'
set :deploy_to, '/var/www/el-dorado'
set :user, 'root'
set :use_sudo, false  # We are already root in this example

role :app, "TARGET_SERVER"
role :web, "TARGET_SERVER"
role :db,  "TARGET_SERVER", :primary => true

before  'deploy:update_code', 'deploy:web:disable' 
after   'deploy:update_code', 'deploy:config_database'
after   'deploy:update_code', 'deploy:config_servers'
after   'deploy:update_code', 'deploy:create_symlinks'
after   'deploy:restart', 'deploy:cleanup'
after   'deploy:restart', 'deploy:web:enable'

namespace :deploy do
  task :restart do
    begin run "/usr/bin/mongrel_rails stop -P #{shared_path}/log/mongrel.#{mongrel_port}.pid"; rescue; end; sleep 15;
    begin run "/usr/bin/mongrel_rails start -d -e production -p #{mongrel_port} -P log/mongrel.#{mongrel_port}.pid -c #{release_path} --user root --group root"; rescue; end; sleep 15;
  end
  task :config_database do
    put(File.read('config/database.yml'), "#{release_path}/config/database.yml", :mode => 0444)
    # For security consider uploading a production-only database.yml to your server and using this instead:
    # run "cp #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  task :config_servers do
    put(File.read('script/spin'), "#{release_path}/script/spin", :mode => 0444)
    run "chmod 755 #{release_path}/script/spin"
    put(File.read('./eldorado'), "/etc/nginx/sites-available/eldorado", :mode => 0444)
    run "ln -s /etc/nginx/sites-available/eldorado /etc/nginx/sites-enabled/eldorado"
    run "rm /etc/nginx/sites-enabled/default"
    run "/etc/init.d/nginx start"
  end
  task :create_symlinks do
    require 'yaml'
    download "#{release_path}/config/symlinks.yml", "/tmp/eldorado_symlinks.yml"
    YAML.load_file('/tmp/eldorado_symlinks.yml').each do |share|
      run "rm -rf #{release_path}/public/#{share}"
      run "mkdir -p #{shared_path}/system/#{share}"
      run "ln -nfs #{shared_path}/system/#{share} #{release_path}/public/#{share}"
    end
  end
end

namespace :rake do
  desc "Show the available rake tasks."
  task :show_tasks do
    run("cd #{deploy_to}/current; /usr/bin/rake -T")
  end
  task :db_create_sqlite do
    run("cd #{deploy_to}/current; /usr/bin/rake db:create")
  end
  task :db_schema_load_sqlite do
    run("cd #{deploy_to}/current; /usr/bin/rake db:schema:load")
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