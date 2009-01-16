#!/bin/bash

#   This script will connect to your server, currently supporting Ubuntu 8.x with other targets planned, 
#	install the necessary applications and libraries to serve production Ruby on Rails applications.  It 
#	will then deploy an application you choose from those available.  
#
#	The script and its related configuration files are an extension are a superset of the original, 
#	basic configuration script available at: http://github.com/mmond/configuration-automation. This version, 
#	introduces menu driven configuration choices like the target server and Rails application to deploy. 
#	Possible configuration options to add in the future: different operating system target, 
#	different versions of Ruby/Rails/other,install locations, multiple server targets and Puppet.
#  	
#	This script includes the following versions, at the time of this writing:
#		Ruby 1.8.7 			Rails 2.2.2	
#		Rubygems 1.3
#		
#	Services:
#		MySQL				Phusion Passenger
#								
#			
#	
#	Rails Applications:	 
#		Hello World 		Eldorado

#	Get the target server 
if [ -z "${TARGET_SERVER}" ]; then 
	echo "Please enter the remote server IP address or hostname:"
	read -e TARGET_SERVER
fi

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

#	Install MySQL
apt-get -y install mysql-server libmysqlclient15-dev mysql-client

#    Install Ruby 
apt-get -y install ruby ruby1.8-dev libopenssl-ruby1.8 

#    Install rubygems v.1.3 from source.  
RUBYGEMS="rubygems-1.3.1"
wget http://rubyforge.org/frs/download.php/45905/$RUBYGEMS.tgz
tar xzf $RUBYGEMS.tgz
cd $RUBYGEMS
ruby setup.rb
cd ..
ln -s /usr/bin/gem1.8 /usr/bin/gem

#    Install gems
gem install rails --no-rdoc --no-ri  
gem install mysql tzinfo passenger sqlite3-ruby --no-rdoc --no-ri

#	Install and configure Apache for Passenger/Rails
apt-get -y install apache2-mpm-prefork apache2-prefork-dev
yes '' | passenger-install-apache2-module

###	Phusion Passenger ###

echo "
#	Phusion Passenger Configuration
LoadModule passenger_module /usr/lib/ruby/gems/1.8/gems/passenger-2.0.6/ext/apache2/mod_passenger.so
PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-2.0.6
PassengerRuby /usr/bin/ruby1.8

ServerName	$HOSTNAME
" >> /etc/apache2/apache2.conf

#	Create a vhost for the test application
echo "<VirtualHost *:80>
   ServerName hello.onlinerailsapps.com
   DocumentRoot /var/www/hello/app/views/welcome
   DirectoryIndex hello.html.erb
</VirtualHost>
" > /etc/apache2/sites-available/hello

ln -s /etc/apache2/sites-available/hello /etc/apache2/sites-enabled/hello

#	Configure a simple Rails Application
cd /var/www
rails hello
cd hello
./script/generate controller welcome hello
echo "<html><h1>Hello World</h1></html>" > app/views/welcome/hello.html.erb

#	Set permissions to support Passenger
chown -R www-data.www-data /var/www

#	Load updated Apache configuration
/etc/init.d/apache2 reload

#	Misc
updatedb
'
echo "

Enjoy your Rails server! The Hello World test app is available at http://hello."$TARGET_SERVER

#	Install any Rails applications?
source configure_rails_apps.sh
