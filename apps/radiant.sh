#	Deploy Radiant via Capistrano
#	Radiant already has a great demo at demo.radiant.org.  Also the new recommended
#	install method is crazy simple via their gem.  Still pushing one button is 
#	faster and more reliable than installing or reinstalling, updating Passenger, etc.
#	Also, we'll install from source, allow you to modify the app locally and deploy
#	via Capistrano.


#	If TARGET_SERVER is not set by parent script, ask for it
if [ -z "${TARGET_SERVER}" ]; then 
	echo "Please enter the remote server IP address or hostname:"
	read -e TARGET_SERVER
fi


#	download Radiant from Github to ~/radiant 
echo "In a moment Capistrano will request your password.
"
mkdir -p radiant/config
cd radiant/
capify .


#	Use configuration-automation's Radiant deploy.rb
#	Update the TARGET_SERVER placeholder in deploy.rb
cat ../config/radiant.deploy.rb |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > radiant/config/deploy.rb

#	Use configuration-automation's Radiant vhost
#	Update the TARGET_SERVER placeholder in the Apache vhost
cat ../config/radiant.vhost |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > radiant/config/radiant.vhost

#	Use configuration-automation's Radiant database.yml
cp ../config/radiant.database.yml radiant/config/database.yml

#	Use Capistrano to configure directory structure, Radiant and servers
cap deploy:setup deploy:update deploy:upload_conf_files deploy:symlink_vhost deploy:chown_web deploy:create_db rake:db_bootstrap passenger:restart

#	Go back to configuration-automation root dir (to allow all app installs)
cd ..