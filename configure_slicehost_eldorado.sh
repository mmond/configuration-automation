#   This script will remotely configure your Slicehost VPS with the necessary applications and libraries
#   to serve and monitor production Ruby on Rails applications.  It's intended to run from a bare Ubuntu
#	8.0.4 installation, for example a new Slicehost VPS build.  This script and its related configuration
#	files are extension are a superset of the original, mimimal configuration script. (So it should noe be 
#	run on after running that version)
#	
#	The previous script is available at: http://github.com/mmond.  It installed:
#   	Ruby 1.8.6 
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
#		Eldorado full stack community web portal  
#	

#	Edit the following line with your slice's IP or domain name
TARGET='YOURACCOUNT.slicehost.com'		# e.g. TARGET='fiveruns.slicehost.com'	

#	Make first remote ssh connection
ssh root@$YOURACCOUNT.slicehost.com '

#	Add alias for ll	(Dear Ubuntu: This should be default)
echo "alias \"ll=ls -lAgh\"" >> /root/.profile

#    Update Ubuntu package manager
#
apt-get update
apt-get upgrade -y

#    Install dependencies
#
apt-get -y install build-essential libssl-dev libreadline5-dev zlib1g-dev  
apt-get -y install libsqlite-dev libsqlite3-ruby libsqlite3-dev 
apt-get -y install mysql-server libmysqlclient15-dev mysql-client 
apt-get -y install git-core locate nginx

#	Create the Eldorado database
mysql -e "create database eldorado_production"

#    Install Ruby 
apt-get -y install ruby ruby1.8-dev irb ri rdoc libopenssl-ruby1.8 

#    Install rubygems v.1.2 from source.  apt-get installs
#    version 0.9.4 requiring a lengthy rubygems update
RUBYGEMS="rubygems-1.2.0"
wget http://rubyforge.org/frs/download.php/38646/$RUBYGEMS.tgz
tar xzf $RUBYGEMS.tgz
cd $RUBYGEMS
ruby setup.rb
cd ..
ln -s /usr/bin/gem1.8 /usr/bin/gem

#    Install gems
# 
gem install -v=2.1.0 rails --no-rdoc --no-ri  
gem install mysql mongrel tzinfo thin --no-rdoc --no-ri

#    Download FiveRuns Manage  ** Installation and registration is run seperately **
#    If are new to FiveRuns, sign up for a free 30 day trial:  https://manage.fiveruns.com/signup
#    After, you have created an account, just execute the downloaded installer.
#
cd /tmp
wget http://manage.fiveruns.com/system/downloads/client/manage-installer-linux-ubuntu-64bit-intel.sh

#    Install the Manage gem and echoe gem dependency
#
gem install fiveruns_manage --source http://gems.fiveruns.com
gem install echoe --no-ri --no-rdoc

'
#	Deploy Eldorado via Capistrano configure_slicehost_eldorado.sh will 
#	download Eldorado from Github to ~/el-dorado 
git clone git://github.com/trevorturk/el-dorado.git
cd el-dorado
#	Use the customized Slicehost Eldorado deploy.rb and database.yml files
wget http://github.com/mmond/configuration-automation/tree/master%2Feldorado.deploy.rb?raw=true -O config/deploy.rb   
wget http://github.com/mmond/configuration-automation/tree/master%2Feldorado.database.yml.txt?raw=true -O config/database.yml
wget http://github.com/mmond/configuration-automation/tree/master%2Fspin?raw=true -O script/spin
cap deploy:setup deploy:update 


#	Make second remote ssh connection
# 	Replace YOURACOUNTNAME with your target server IP or domain name  
ssh root@$YOURACCOUNT.slicehost.com '
cd /var/www/el-dorado/current
#	Run rake tasks
rake db:create RAILS_ENV=production
rake db:schema:load RAILS_ENV=production
rake db:migrate RAILS_ENV=production
'

#	Start the servers
cap deploy:start





