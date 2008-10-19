#!/bin/bash

#   This script will connect to your Ubuntu 8.0.4 server, install all the necessary applications and 
#   libraries to serve production Ruby on Rails applications and deploy the Eldorado full stack community.  
#	The script and its related configuration files are an extension are a superset of the original, 
#	basic configuration script for a new Slicehost Ubuntu server. 
#	
#	The previous script is available at: http://github.com/mmond.  It installed:
#		Ruby 1.8.6 
#		Rubygems 1.2
#		Rails 2.1.0
#		Sqlite3
#		MySQL 5.0.51a
#		Thin 0.8.2
#		Hello World example Rails application
#  	
#	This version of script includes the above and:
#		nginx
#		Capistrano
#		Mongrel
#		Eldorado full stack community web application  
#	

echo -n "Please enter your the remote server IP or domain name"
read -e TARGET_SERVER

#	Make first remote ssh connection
ssh root@$TARGET_SERVER '

#	Add alias for ll	(Dear Ubuntu: This should be default)
echo "alias \"ll=ls -lAgh\"" >> /root/.profile

#    Update Ubuntu package manager
apt-get update
apt-get upgrade -y

#   Install dependencies
apt-get -y install build-essential libssl-dev libreadline5-dev zlib1g-dev 

#	Install misc helpful apps
apt-get -y install git-core locate telnet elinks

#	Install servers
apt-get -y install libsqlite-dev libsqlite3-ruby libsqlite3-dev 
apt-get -y install mysql-server libmysqlclient15-dev mysql-client 
apt-get -y install nginx

#    Install Ruby 
apt-get -y install ruby ruby1.8-dev irb ri rdoc libopenssl-ruby1.8 

#    Install rubygems v.1.3 from source.  apt-get installs
#    version 0.9.4 requiring a lengthy rubygems update
RUBYGEMS="rubygems-1.3.0"
wget http://rubyforge.org/frs/download.php/43985/$RUBYGEMS.tgz
tar xzf $RUBYGEMS.tgz
cd $RUBYGEMS
ruby setup.rb
cd ..
ln -s /usr/bin/gem1.8 /usr/bin/gem

#    Install gems
gem install -v=2.1.0 rails --no-rdoc --no-ri  
gem install mysql mongrel tzinfo thin --no-rdoc --no-ri
'
#	Deploy Eldorado via Capistrano:  configure_slicehost_eldorado.sh will 
#	download Eldorado from Github to ~/el-dorado 
git clone git://github.com/trevorturk/el-dorado.git
cd el-dorado
#	Use automation configured deploy.rb, spin and database.yml files
wget http://github.com/mmond/configuration-automation/tree/master%2Feldorado.deploy.rb?raw=true -O config/generic.deploy.rb  
#	Update the TARGET_SERVER placeholders in deploy.rb
cat config/generic.deploy.rb |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > config/deploy.rb
rm config/generic.deploy.rb
#	Download other configuration files
wget --timeout=10 --waitretry=1 http://github.com/mmond/configuration-automation/tree/master%2Feldorado.nginx.conf?raw=true -O eldorado  
wget --timeout=10 --waitretry=1 http://github.com/mmond/configuration-automation/tree/master%2Feldorado.database.yml.txt?raw=true -O config/database.yml
wget --timeout=10 --waitretry=1 http://github.com/mmond/configuration-automation/tree/master%2Fspin?raw=true -O script/spin
#	Use Capistrano to configure directory structure, Eldorado and servers
cap deploy:setup deploy:update 

#	Make second remote ssh connection for database configuration.  
ssh root@$TARGET_SERVER.slicehost.com '
cd /var/www/el-dorado/current		
#	Configure SQLite
rake db:create 
rake db:schema:load 
#	Configure MySQL
rake db:create RAILS_ENV=production
rake db:schema:load RAILS_ENV=production
rake db:migrate RAILS_ENV=production
'

#	Start the servers
cap deploy:start





