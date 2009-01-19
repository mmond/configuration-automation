#	Deploy jobberRails via Capistrano
#

#	If TARGET_SERVER is not set by parent script, ask for it
if [ -z "${TARGET_SERVER}" ]; then 
	echo "Please enter the remote server IP address or hostname:"
	read -e TARGET_SERVER
fi


#	download jobberRails from Github to ~/jobberRails 
echo "In a moment Capistrano will request your password.
"
cd ..
git clone git://github.com/jcnetdev/jobberrails.git jobberrails
cd jobberrails/

#	Use configuration-automation's jobberRails deploy.rb
#	Update the TARGET_SERVER placeholder in deploy.rb
cat ../configuration-automation/config/jobberrails.deploy.rb |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > config/deploy.rb

#	Use configuration-automation's jobberRails vhost
#	Update the TARGET_SERVER placeholder in the Apache vhost
cat ../configuration-automation/config/jobberrails.vhost |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > config/jobberrails.vhost

#	Use configuration-automation's jobberRails database.yml
cp ../configuration-automation/config/jobberrails.database.yml config/database.yml

#	Use Capistrano to configure directory structure, jobberRails and servers
cap deploy:setup deploy:update deploy:upload_conf_files deploy:symlink_vhost rake:gems_install deploy:chown_web rake:db_create rake:db_schema_load rake:db_migrate passenger:restart
