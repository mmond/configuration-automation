
#	Prompt for the app to install
printf "Which Rails application would you like to install?\n"
printf "1. El Dorado\n"
printf "2. Spree\n"
printf "3. Typo\n"
printf "4. Radiant\n"
printf "Default (3): " ; read RAILS_APPLICATION

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
