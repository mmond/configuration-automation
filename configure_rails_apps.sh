#	This is stage 2 of configuration-automation: Installing Rails Apps
#	It can be run independently of configure_ubuntu.sh from the same dir.

echo "
To install a production Rails application, choose from the list or [CTRL-C] to quit"
echo "The choices are: "
printf "Which Rails application would you like to install?\n"
printf "1. El Dorado\n"
printf "2. Spree\n"
printf "3. Typo\n"
printf "4. Radiant\n"
printf "Default (1): " ; read RAILS_APPLICATION

case $RAILS_APPLICATION in
1)
	source apps/eldorado.sh
	;;
2)
	source apps/spree.sh
	;;
3)
	source apps/typo.sh
	;;
4)
	source apps/radiant.sh
	;;
*)
	echo $RAILS_APPLICATION: unknown option >&2
	exit 1
	;;
esac

exit 1
