#	This is stage 2 of configuration-automation: Installing Rails Apps
#	It is called by configure_ubuntu.sh but can also be run directly 
#	from the same ./configuration-automation directory.

echo "
To install a production Rails application, choose from the list or [CTRL-C] to quit
The choices are: "
echo "1. Radiant CMS"
echo "2. El Dorado Community Web App"
printf "Default (1): " ; read RAILS_APPLICATION

case $RAILS_APPLICATION in
"", 1)
	source apps/radiant.sh
	;;
2)
	source apps/eldorado.sh
	;;
*)
	echo $RAILS_APPLICATION: unknown option >&2
	exit 1
	;;
esac

exit 1
