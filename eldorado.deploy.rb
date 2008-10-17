load 'deploy' if respond_to?(:namespace) # cap2 differentiator

set :repository, 'git://github.com/trevorturk/el-dorado.git'
set :scm, :git
set :deploy_via, :copy
set :copy_cache, true
set :git_shallow_clone, 1

set :application, 'eldorado'
set :deploy_to, '/var/www/el-dorado'
set :mongrel_port, '8000'
set :user, 'root'
set :use_sudo, false  # We are already root in this example

role :app, "YOURACCOUNT.slicehost.com"
role :web, "YOURACCOUNT.slicehost.com"
role :db,  "YOURACCOUNT.slicehost.com", :primary => true

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
    put(File.read('./eldorado.nginx.conf'), "/etc/nginx/sites-available/eldorado", :mode => 0444)
    run "ln -s /etc/nginx/sites-available/eldorado /etc/nginx/sites-enabled/eldorado"
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