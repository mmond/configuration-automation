#	Deploy Eldorado via Capistrano
#	If TARGET_SERVER is not set by parent script, ask for it
#	Get the target server 
echo "Please enter the remote server IP address or hostname:"
read -e TARGET_SERVER


#	download Eldorado from Github to ~/el-dorado 
git clone git://github.com/trevorturk/el-dorado.git
mv el-dorado eldorado
cd eldorado/config

#	Use configuration-automation's permalinked eldorado deploy.rb
wget --timeout=10 --waitretry=1 http://github.com/mmond/configuration-automation/raw/be814b9c6d5ebca8298dc99cbfbb4b8e15fd5667/config/eldorado.deploy.rb
#	Update the TARGET_SERVER placeholders in deploy.rb
cat eldorado.deploy.rb |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > deploy.rb

#	Use configuration-automation's permalinked eldorado vhost
wget --timeout=10 --waitretry=1 http://github.com/mmond/configuration-automation/raw/be814b9c6d5ebca8298dc99cbfbb4b8e15fd5667/config/eldorado.vhost
#	Update the TARGET_SERVER placeholders in the Apache vhost
cat eldorado.vhost |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > eldorado

#	Use configuration-automation's permalinked eldorado database.yml
wget --timeout=10 --waitretry=1 http://github.com/mmond/configuration-automation/tree/master%2Feldorado.database.yml.txt?raw=true -O database.yml

#	Use Capistrano to configure directory structure, Eldorado and servers
cd ..
cap deploy:setup deploy:update rake:db_create rake:db_schema_load rake:db_migrate deploy:start
