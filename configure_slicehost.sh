#    This script will remotely configure your Slicehost VPS with the necessary applications and libraries
#    to serve and monitor a production Ruby on Rails application.  A simple "Hello World" Rails
#    Application is installed and started to confirm the process.
#  
#    Versions installed are Ruby 1.8.6, Rubygems 1.2, Rails 2.1.0. Sqlite3, MySQL 5.0.51a, Thin 0.8.2

#    Make remote ssh connection   (substitue your target server's address)
#  

#	Edit the following line with your slice's IP or domain name
ssh root@fiveruns.slicehost.com '

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
#    If you are new to FiveRuns, sign up for a free trial:  https://manage.fiveruns.com/signup
#    After, you have created an account, just execute the installer that's downloaded here
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
/usr/sbin/update-rc.d -f thin defaults
thin -p 80 config -C /etc/thin/hello.yml -c /var/www/hello
/etc/init.d/thin start
'

