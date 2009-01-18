#	This is stage 2 of configuration-automation: Installing Rails Apps
#	It is called by configure_ubuntu.sh but can also be run directly 
#	from the same ./configuration-automation directory.

echo "
To install a production Rails application, choose from the list or [CTRL-C] to quit
The choices are: "
echo "0. None"
echo "1. Radiant CMS"
echo "2. El Dorado"
echo "3. Spree"
printf "Default (0): " ; read RAILS_APPLICATION

case $RAILS_APPLICATION in
0)
	echo $RAILS_APPLICATION: Ok. Enjoy your server! >&2
	exit 1
	;;
1)
	source apps/radiant.sh
	;;
2)
	source apps/eldorado.sh
	;;
3)
	source apps/spree.sh
	;;
*)
	echo $RAILS_APPLICATION: That is an unknown option. Exiting... >&2
	exit 1
	;;
esac

exit 1
