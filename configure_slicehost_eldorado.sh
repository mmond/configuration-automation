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
TARGET='YOURACCOUNT.slicehost.com'		# e.g. fiveruns.slicehost.com

#	Create local repository for Eldorado.  configure_slicehost_eldorado.sh will download  
#	Eldorado from Github to ~/el-dorado 
git clone git://github.com/trevorturk/el-dorado.git
#	Update the deploy.rb file.  !!!!!!!!!!!!!!!!!!!!!!!!!!!For now we'll use a manually edited YOURACCOUNT.slicehost.com    !!!!!!!!!!!!!!!!!!!!!!!!!
#	Use the Eldorado application directory structure.  Doing this now allows us to copy the preconfigured database.yml
cap deploy:setup

#	Make remote ssh connection
# 	Replace YOURACOUNTNAME with your target server IP or domain name  
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

#    Install Ruby 
#
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

#	Download the custom database.yml for Eldorado
cd /var/www/eldorado/config
wget http://github.com/mmond/configuration-automation/tree/master/eldorado_database.yml
mv eldorado_database.yml database
'
#	Deploy Eldorado via Capistrano
cap deploy:check
cp eldorado.database.yml el-dorado/config/datatabase.yml   #  This should fix the following error : the database.yml file does not yet exist.    !!!!!!!!!!!!!!!!!!!!!!!!!
cap deploy:update		

#	Configure Database YAML file??



#	*******************This should all happen via Cap now *******************


#	This section installs a production copy of the Eldorado Community web portal to a preconfigured 
#	Slicehost VPS.  It can be modified to support local Ubuntu environments, VM's, etc. 
#	
#	Other common Rails related defaults at the time of this writing are Apache, Passenger, nginx and 
#	Mongrel.  We installed Thin originally as the web front end, so let's leave that serving the 
#	Hello World app on port 8080.  We'll add Mongrel to the application layer to serve Eldorado and 
#	install nginx as our web server on default port 80.


#	We need to download and configure our local copy of the app. The target URL will  
#	likely change, so check http://github.com/trevorturk for most current updates	
wget http://github.com/trevorturk/el-dorado/tarball/v0.9.2
tar zxf trevorturk-el-dorado-a7ead776a85e5eccaa065d5a12319772fdfb7767.tar.gz
rm trevorturk-el-dorado-a7ead776a85e5eccaa065d5a12319772fdfb7767.tar.gz
#	This filename is long so we'll simplify it
mv trevorturk-el-dorado-a7ead776a85e5eccaa065d5a12319772fdfb7767 eldorado

#	Use the prepopulated YAML configuration 
#	You should change secrets for external/production use.
cd eldorado
cp ./eldorado.example.yml config/database.yml

#	Use Capistrano to deploy Eldorado to Slicehost
capify .


