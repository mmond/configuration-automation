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
mkdir -p jobberrails/config
cd jobberrails/
capify .


#	Use configuration-automation's jobberRails deploy.rb
#	Update the TARGET_SERVER placeholder in deploy.rb
cat ../config/jobberrails.deploy.rb |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > jobberrails/config/deploy.rb

#	Use configuration-automation's jobberRails vhost
#	Update the TARGET_SERVER placeholder in the Apache vhost
cat ../config/jobberrails.vhost |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > jobberrails/config/jobberrails.vhost

#	Use configuration-automation's jobberRails database.yml
cp ../config/jobberrails.database.yml jobberrails/config/database.yml

#	Use Capistrano to configure directory structure, jobberRails and servers
cap deploy:setup deploy:update deploy:upload_conf_files deploy:symlink_vhost deploy:haml_install deploy:rails_install rake:gems_install deploy:chown_web rake:db_create rake:db_schema_load rake:db_migrate passenger:restart

#	Go back to configuration-automation root dir (to allow all app installs)
cd ..