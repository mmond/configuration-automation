#    This script will remotely configure your Slicehost VPS with the necessary applications and libraries
#    to serve a production Ruby on Rails application.  
#  
#    Versions installed are Ruby 1.8.6, Rubygems 1.2, Rails 2.1.0. Sqlite3, MySQL 5.0.51a, Thin 0.8.2

#    Make remote ssh connection   (substitue your target server's address)
#  

#	Edit the following line with your slice's IP or domain name
ssh root@fiveruns.slicehost.com '

#	Add alias for ll	(Dear Ubuntu: This should be the default)
echo "alias \"ll=ls -lAgh\"" >> /root/.profile

#   Update Ubuntu package manager
#
apt-get update
apt-get upgrade -y

#   Install dependencies
apt-get -y install build-essential libssl-dev libreadline5-dev zlib1g-dev 

#	Install misc helpful apps
apt-get -y install git-core locate telnet 

#	Install servers
apt-get -y install libsqlite-dev libsqlite3-ruby libsqlite3-dev 
apt-get -y install mysql-server libmysqlclient15-dev mysql-client 
apt-get -y install nginx

#   Install Ruby 
#
apt-get -y install ruby ruby1.8-dev irb ri rdoc libopenssl-ruby1.8 

#   Install rubygems v.1.2 from source.  apt-get installs
#   version 0.9.4 requiring a lengthy rubygems update
RUBYGEMS="rubygems-1.2.0"
wget http://rubyforge.org/frs/download.php/38646/$RUBYGEMS.tgz
tar xzf $RUBYGEMS.tgz
cd $RUBYGEMS
ruby setup.rb
cd ..
ln -s /usr/bin/gem1.8 /usr/bin/gem

#   Install gems
# 
gem install -v=2.1.0 rails --no-rdoc --no-ri  
gem install mysql  --no-rdoc --no-ri
gem install tzinfo mysql thin mongrel --no-rdoc --no-ri

'

