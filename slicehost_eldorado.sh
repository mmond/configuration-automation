#	This script installs a production copy of the Eldorado Community web portal 
#	to a configured Slicehost VPS.  It can be easily modified to support local 
#	environments, VM's, etc.
#
#	This script assumes you have already prepped your VPS with:
#	Ruby 1.8.6, Rubygems 1.2, Rails 2.1.0. Sqlite3, MySQL 5.0.51a, Thin 0.8.2
#	or other compatible versions.  configuration_automation.sh is available at
#	Github and will build those configurations.  Also, Capistrano is required 
#	locally to deploy the Eldorado application to Slicehost
#
#	Move to the parent directory of where you'd like to install eldorado and
#	execute the script.  Eldorado will install to ./eldorado

#	Collect the MySQL credentials to set Eldorado's deploy user/pass
#	 
echo -n "We need to create Eldorado's database credentials."
echo -n "Please enter your MySQL administrative user: "
read -e USER	
echo -n "Please enter your MySQL administrative user's password.  (It will not be echoed) "
read -e -s PASS
echo -n "Choose the Eldorado's db password now.  (It will not be echoed) "
read -e -s PASS

#	We need to download and configure our local copy of the app. The target URL will  
#	likely change, so check http://github.com/trevorturk for most current updates	
wget http://github.com/trevorturk/el-dorado/tarball/v0.9.2
tar zxf trevorturk-el-dorado-a7ead776a85e5eccaa065d5a12319772fdfb7767.tar.gz

#	This filename scheme is a bit ardous so we'll simplify it
mv trevorturk-el-dorado-a7ead776a85e5eccaa065d5a12319772fdfb7767 eldorado


#	
cd eldorado

#	Add credentials and secret to production section. 
#	This section edits the default Eldorado database.example.yml file,
#	creating a working databases.yml 

#	Generate a random, 30 character secret string
SECRET_VALUE=RSTR$( perl -e 'while($c<30){ $v=rand(123); next if ($v<48||($v>57&&$v<65)||($v>90&&$v<97)); print(chr($v)); $c++}' )

NEW_SECRET="secret: $SECRET_VALUE"

#	Replace the ORIG with the NEW

#	This is such a hack, but I cannot get sed to recognize the newline character
# substitute "foo" with "bar" EXCEPT for the other "secret:" lines which contain a "J" character
cat ./database.example.yml |sed "/J/!s/$SECRET_NAME/$NEW_SECRET/g" > ./database.tmp       


cat ./database.tmp |sed "s/password: /password:\ $NEW/g" > ./database.yml


cp config/database.example.yml config/database.yml

#	

# Add Eldorado virtual host to Apache2 conf
#
echo '
# Eldorado vhost
#

<VirtualHost *:80>
   ServerName eldorado.fiveruns.com
   DocumentRoot /tmp/eldorado/public
</VirtualHost>

' >> /etc/apache2/apache2.conf

# Restart Apache2
/etc/init.d/apache2 restart


# 
#  Finishing shell options
#
updatedb
