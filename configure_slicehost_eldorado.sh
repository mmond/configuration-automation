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
#		Eldorado full stack community web portal   ###########  ???????????


#	To execute the script, cd to the parent directory of where you'd like the local copy of the Rails apps.
#	Hello World will install to ./hello and Eldorado will install to ./eldorado

 

#	Edit the following line with your slice's IP or domain name
TARGET='YOURACCOUNT.slicehost.com'		# e.g. fiveruns.slicehost.com

#	Make remote ssh connection
# 	Replace YOURACOUNTNAME with your target server IP or domain name  
ssh root@$YOURACCOUNT.slicehost.com '

#    Update Ubuntu package manager
#
apt-get update
apt-get upgrade -y

#    Install dependencies
#
apt-get -y install build-essential libssl-dev libreadline5-dev zlib1g-dev  
apt-get -y install libsqlite-dev libsqlite3-ruby libsqlite3-dev 
apt-get -y install mysql-server libmysqlclient15-dev mysql-client 

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
gem install mysql  --no-rdoc --no-ri
gem install tzinfo mysql thin --no-rdoc --no-ri

#    Configure a simple Rails Application
#
mkdir /var/www/
cd /var/www
rails hello
cd hello
./script/generate controller welcome hello
echo "Hello World" > app/views/welcome/hello.html.erb

#    Download FiveRuns Manage  ** Installation and registration is run seperately **
#    If are new to FiveRuns, sign up for a free trial:  https://manage.fiveruns.com/signup
#    After, you have created an account, just execute the installer below
#
cd /tmp
wget http://manage.fiveruns.com/system/downloads/client/manage-installer-linux-ubuntu-64bit-intel.sh

#    Install the Manage gem and echoe gem dependency
#
gem install fiveruns_manage --source http://gems.fiveruns.com
gem install echoe --no-ri --no-rdoc

#    Install, configure and start the Thin web server
#
thin install
/usr/sbin/update-rc.d -f thin defaults								#	Perhaps this should be Capifed?
thin -p 80 config -C /etc/thin/eldorado.yml -c /var/www/eldorado  	#	Serve Eldorado on 80
thin -p 8080 config -C /etc/thin/hello.yml -c /var/www/hello		#	Serve Hello World on 8080
/etc/init.d/thin start		
'


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


