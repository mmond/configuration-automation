#	Deploy Eldorado via Capistrano
#	If TARGET_SERVER is not set by parent script, ask for it
if [ -z "${TARGET_SERVER}" ]; then 
	echo "Please enter the remote server IP address or hostname:"
	read -e TARGET_SERVER
fi


#	download Eldorado from Github to ~/el-dorado 
cd ..
git clone git://github.com/trevorturk/el-dorado.git
mv el-dorado eldorado
cd eldorado/config

#	Use configuration-automation's eldorado deploy.rb
#	Update the TARGET_SERVER placeholders in deploy.rb
cat ../configuration-automation/config/eldorado.deploy.rb |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > deploy.rb

#	Use configuration-automation's eldorado vhost
#	Update the TARGET_SERVER placeholders in the Apache vhost
cat ../configuration-automation/config/eldorado.vhost |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > eldorado

#	Use configuration-automation's eldorado database.yml
cp ../configuration-automation/config/eldordado.database.yml .

#	Use Capistrano to configure directory structure, Eldorado and servers
cd ..
cap deploy:setup deploy:update deploy:symlink_vhost deploy:upload_conf_files rake:db_create rake:db_schema_load rake:db_migrate deploy:start
