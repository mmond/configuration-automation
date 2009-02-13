#	Deploy Spree via Capistrano
#

#	If TARGET_SERVER is not set by parent script, ask for it
if [ -z "${TARGET_SERVER}" ]; then 
	echo "Please enter the remote server IP address or hostname:"
	read -e TARGET_SERVER
fi


#	download Spree from Github to ~/spree 
echo "In a moment Capistrano will request your password.
"
mkdir -p spree/config
cd spree/
capify .

#	Use configuration-automation's spree deploy.rb
#	Update the TARGET_SERVER placeholder in deploy.rb
cat ../config/spree.deploy.rb |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > spree/config/deploy.rb

#	Use configuration-automation's spree vhost
#	Update the TARGET_SERVER placeholder in the Apache vhost
cat ../config/spree.vhost |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > spree/config/spree.vhost

#	Use configuration-automation's spree database.yml
cp ../config/spree.database.yml spree/config/database.yml

#	Use Capistrano to configure directory structure, spree and servers
cap deploy:setup deploy:update deploy:upload_conf_files deploy:symlink_vhost deploy:gems_install deploy:chown_web deploy:create_db rake:db_bootstrap passenger:restart

#	Go back to configuration-automation root dir (to allow all app installs)
cd ..