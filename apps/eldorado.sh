#	Deploy Eldorado via Capistrano
#	download Eldorado from Github to ~/el-dorado 
git clone git://github.com/trevorturk/el-dorado.git
mv el-dorado eldorado
cd eldorado

#	Use configuration-automation's permalinked eldorado deploy.rb
wget --timeout=10 --waitretry=1 http://github.com/mmond/ file
#	Update the TARGET_SERVER placeholders in deploy.rb
cat config/eldorado.deploy.rb |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > config/deploy.rb
rm config/generic.deploy.rb

#	Use configuration-automation's permalinked eldorado deploy.rb
wget --timeout=10 --waitretry=1 http://github.com/mmond/ file
#	Update the TARGET_SERVER placeholders in the Apache vhost
cat config/eldorado.vhost |sed "s/TARGET_SERVER/$TARGET_SERVER/g" > config/eldorado
rm config/eldorado.vhost

#	Use configuration-automation's permalinked eldorado deploy.rb
wget --timeout=10 --waitretry=1 http://github.com/mmond/configuration-automation/tree/master%2Feldorado.database.yml.txt?raw=true -O config/database.yml

#	Use Capistrano to configure directory structure, Eldorado and servers
cap deploy:setup deploy:update rake:db_create rake:db_schema_load rake:db_migrate deploy:start
