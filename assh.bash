#!/bin/bash

# Where necessary, update the shebang above.
#       It should be bash, not tsch, csh, or sh.
 
if [[ ! -f ~/.assh/config  ]]; then
	mkdir -p ~/.assh
	ASSH_DEFAULT_CONFIG=""
	ASSH_DEFAULT_CONFIG+='ASSH_SCRIPT_PATH="~/git/AutoSSH/"'$'\n'
	ASSH_DEFAULT_CONFIG+='# The following line defines the folder(s) that AutoSSH will look for'$'\n'
	ASSH_DEFAULT_CONFIG+='#	user scripts, so they can be selected from the main menu'$'\n'
	ASSH_DEFAULT_CONFIG+='#	This is a space-separated list.'$'\n'
	ASSH_DEFAULT_CONFIG+='USER_SCRIPT_PATH="~/scripts"'$'\n'
	ASSH_DEFAULT_CONFIG+='RDP_USERNAME="user"'$'\n'
	ASSH_DEFAULT_CONFIG+='# Set the string below to the header you want to see above the list'$'\n'
	ASSH_DEFAULT_CONFIG+='HEADER="ASSH"'$'\n'
	ASSH_DEFAULT_CONFIG+='# Used to hide things the user never needs, but still need to be in the file'$'\n'
	ASSH_DEFAULT_CONFIG+='# Grep Regex format'$'\n'
	ASSH_DEFAULT_CONFIG+='SYSTEMFILTER=""'$'\n'
	ASSH_DEFAULT_CONFIG+='# Set whether window reuse is active (1) or inactive (0) by default'$'\n'
	ASSH_DEFAULT_CONFIG+='WINDOW_REUSE="1"'$'\n'
	echo "$ASSH_DEFAULT_CONFIG" > ~/.assh/config
fi

source ~/.assh/config

# Future code to detect whether ASSH is running in screen (it should be)
#	This code isn't tested. It probably won't work.
#if [ "$STY" == "" ]; then
#	screen -m "cd ${ASSH_SCRIPT_PATH}; ./assh.bash"
#fi
 
# Used to define something the user specifically wants to see
USERFILTER=""
#FANCYDISP=0
clear

while true
do
clear
if [[ -z $1 ]]; then
		echo
		COUNT=1
		DISPCOUNT=1
		HOSTDISPLIST=''
		HOSTACTLIST=''
		HOSTS=''
		HOSTSTEMP=''
		METALIST="$(cat ~/.ssh/config $(find ~/.ssh/config.d/ -type f) | grep host | grep -v hostname | grep -v "*" \
		| grep -Ev "^#" | awk -F' ' '{print $2}' | sort | uniq)"
		for THIS_PATH in $USER_SCRIPT_PATH; do
			METALIST="$METALIST $(find ${THIS_PATH} | grep -E '.sh$|.bash$|.expect$')"
		done
		#echo "$METALIST"
		for HOSTITEM in $(echo "$METALIST")
		do
			# Decide of a host matches the filters, and add it to the list
			ADDEDHOST=$HOSTITEM
			for FILTERITEM in $(echo "$USERFILTER")
			do
				ADDEDHOST="$(echo $ADDEDHOST | grep -E $FILTERITEM)"
			done
			HOSTS="$HOSTS $ADDEDHOST"
			# Display during search
			if [ "$FANCYDISP" == "1" ]; then
				HOSTSTEMP="$(echo "$HOSTS" | sed 's/ /\n/g' | column -x)"
				if [ -n "$ADDEDHOST" ] ; then
					DISPADDEDHOST=$ADDEDHOST
				fi
				if [ "$DISPCOUNT" -lt "10" ] ; then
					printf "    $DISPCOUNT $DISPADDEDHOST                                                                         \r"
				elif [ "$DISPCOUNT" -lt "100" ] ; then
					printf "   $DISPCOUNT $DISPADDEDHOST                                                                         \r"
				else
					printf "  $DISPCOUNT $DISPADDEDHOST                                                                         \r"
				fi
				((DISPCOUNT++))
			fi
		done
		for HOST in $(echo $HOSTS)
		do
			if [ "$COUNT" -lt "10" ] ; then
				HOSTDISPLIST="$HOSTDISPLIST   $COUNT: $HOST"$'\n'
			elif [ "$COUNT" -lt "100" ] ; then
				HOSTDISPLIST="$HOSTDISPLIST  $COUNT: $HOST"$'\n'
			else
				HOSTDISPLIST="$HOSTDISPLIST $COUNT: $HOST"$'\n'
			fi
			HOSTACTLIST[$COUNT]="$HOST"
			#HOSTACTLIST[$COUNT]="$HOST"$'\n'
			((COUNT++))
		done
		clear
		echo
		for THIS_PATH in $USER_SCRIPT_PATH; do
			HOSTDISPLIST="$(echo "$HOSTDISPLIST" | sed "s|$THIS_PATH/*|script:|g")"
		done
		echo $HEADER | column -t
		echo
		echo "$HOSTDISPLIST" | column
		echo
		if [ "$USERFILTER" ]; then
			echo "Current filter:"
			echo "$USERFILTER"
			echo
		fi
#			echo '[blank] - Refresh'
#			echo '	 f - [F]ilter (edit current)'
#			echo '	ff - [FF]ilter (blank prompt)'
#			echo '	 e - [E]dit'
#			echo '	 c - Show [c]onfig for listed servers'
#			echo "	 d - Toggle fancy [D]isplay (current: $FANCYDISP)"
#			echo '	 x - E[x]it'
#			echo
#			read -p "Select server: " SELECTION
#		echo
#		#IFS=$'\r\n'
#		# Set list for of options for the menu
#		OPTIONS=($(cat ~/.ssh/config ~/.ssh/config.d/* | grep host | grep -v hostname | grep -v "*" \
#			| grep -Ev "^#" | awk -F' ' '{print $2}' | sort | uniq))
#		#OPTIONS+=($(ls -1 ${USER_SCRIPT_PATH}))
#		# Find the scripts
#		OPTIONS+=($(find ${USER_SCRIPT_PATH} | grep -E '.bash$|.sh$'))
#		# Take the user-defined script path out of the display name for the scripts
#		IFS=" "
#		for THIS_PATH in $(echo "${USER_SCRIPT_PATH}")
#		do
#			IFS=$'\n'
#			OPTIONS=($(echo "${OPTIONS[*]}" | sed "s|$THIS_PATH||g"))
#		done
#		# Filter entries based on config file and user defined filter
#		IFS=" "
#		for FILTERITEM in $(echo "$USERFILTER")
#		do
#			IFS=$'\n'
#			OPTIONS=($(echo "${OPTIONS[*]}" | grep -E $FILTERITEM))
#		done
		# Set a list of additional, non-numerical options
		EXTRA_OPTIONS=""
		EXTRA_OPTIONS+=" [blank]: Refresh"$'\n'
		EXTRA_OPTIONS+="       f: [F]ilter (edit current)"$'\n'
		EXTRA_OPTIONS+="      ff: [FF]ilter (blank prompt)"$'\n'
#		EXTRA_OPTIONS+="       e: [E]dit"$'\n'
		EXTRA_OPTIONS+="       c: Show [c]onfig for listed servers"$'\n'
		if [[ "$WINDOW_REUSE" = "1" ]]; then
			EXTRA_OPTIONS+="\033[1m       w: [W]indow Reuse\033[0m"$'\n'
		else
			EXTRA_OPTIONS+="       w: [W]indow Reuse"$'\n'
		fi
		EXTRA_OPTIONS+="       x: E[x]it"$'\n'
		echo
		echo -e "$EXTRA_OPTIONS";
#		echo $HEADER | column -t
#		echo
#		IFS=$'\n'; for I in $(echo "${!OPTIONS[*]}"); do echo "$I: ${OPTIONS[$I]}"; done | awk '{printf "%6s %s \n", $1, $2}' | column
#		if [ "$USERFILTER" ]; then
#			echo
#			echo "Current filter:"
#			echo "$USERFILTER"
#		fi
		read -p "Select server: " SELECTION
		case $SELECTION in
			'')
				# Catching blank entry. Do nothing, restart loop.
			;;
			w)
				# Toggle window reuse
				if [[ "$WINDOW_REUSE" = "1" ]]; then
					WINDOW_REUSE="0"
				else
					WINDOW_REUSE="1"
				fi
			;;
			c)
				read -p "Showing config lines for listed servers in 'less'; (press enter to continue...)"
				CONFIGLINES="$(echo "")"
				for THISHOST in $HOSTDISPLIST; do
					CONFIGLINES="$CONFIGLINES"$'\n'"$(cat ~/.ssh/config ~/.ssh/config.d/* | grep -Ev '^#' | sed -e "/host $THISHOST/,/host /!d" | head -n"-1")"
					#echo '~~~~~~'
				done
				CONFIGLINES="$CONFIGLINES"$'\n'"$(echo "")"
				echo "$CONFIGLINES"$ | grep -Ev '^$|^\s*$' | less
			;;
#			c)
#				read -p "Showing config lines for listed servers in 'less'; (press enter to continue...)"
#				CONFIGLINES="$(echo "")"
#				for THISHOST in $HOSTDISPLIST; do
#					CONFIGLINES="$CONFIGLINES"$'\n'"$(cat ~/.ssh/config | grep -Ev '^#' | sed -e "/host $THISHOST/,/host /!d" | head -n"-1")"
#					#echo '~~~~~~'
#				done
#				CONFIGLINES="$CONFIGLINES"$'\n'"$(echo "")"
#				echo "$CONFIGLINES"$ | grep -Ev '^$|^\s*$' | less
#			;;
			d)
				if [ "$FANCYDISP" == "0" ]; then
					FANCYDISP=1
				else
					FANCYDISP=0
				fi
			;;
			e)
				#Exit condition
				vim ~/.ssh/config
			;;
			x)
				#Exit condition
				break
			;;
			ff)
				# Filter condition
				echo
				echo "Blank filters show all"
				echo "Space-seperated list matches servers containing all terms"
				read -p "Define filter (blank to clear filter): " -e USERFILTER
			;;
			f)
				# Filter condition
				echo
				echo "Blank filters show all"
				echo "Space-seperated list matches servers containing all terms"
				read -p "Define filter (blank to clear filter): " -i "$USERFILTER" -e USERFILTER
			;;
			[0-9]*)
				# if condition to determine if I need a new screen tab, or just to start RDP
				if [[ "${HOSTACTLIST[$SELECTION]}" =~ bash$ ]]; then
					screen -t ${HOSTACTLIST[$SELECTION]} bash -c "bash ${HOSTACTLIST[$SELECTION]}; echo; echo; read -p 'Continue (end)...'"
				elif [[ "${HOSTACTLIST[$SELECTION]}" =~ expect$ ]]; then
					screen -t ${HOSTACTLIST[$SELECTION]} bash -c "expect ${HOSTACTLIST[$SELECTION]}; echo; echo; read -p 'Continue (end)...'"
				elif [[ "${HOSTACTLIST[$SELECTION]}" =~ ^rdp ]]; then
					while [ -z "${ACE_RDP_PASSWORD}" ]; do
						read -s -p "Enter RDP Password: " ACE_RDP_PASSWORD
						echo
					done
					echo
					echo "1: 1279x683 2: 2550x1355"
					read -s -p "Choose Res: " ACE_RDP_RES_SELECT
					case $ACE_RDP_RES_SELECT in
						1)
							ACE_RDP_RES="1279x683"
						;;
						2)
							ACE_RDP_RES="2550x1355"
						;;
						*)
							ACE_RDP_RES="1279x683"
						;;
					esac
					# The hostname it will attempt to connect to is the named entry in ssh/config minus the "rdp_" prefix
					RDP_CMD="xfreerdp /clipboard /size:${ACE_RDP_RES} /u:${RDP_USERNAME} /p:${ACE_RDP_PASSWORD} /v:$(echo "${HOSTACTLIST[$SELECTION]}" | sed 's/^rdp_//')"
					echo $RDP_CMD | sed 's/\/p:.*/\/p:******/g'
					read -p "Continue? (enter|ctrl+c)"
					screen -t ${HOSTACTLIST[$SELECTION]} bash -c "$RDP_CMD"
				else
#					# Newtab/Connection condition
#					ASSHRESULT="$(screen -Q select ${HOSTACTLIST[$SELECTION]})"
#					if [[ -n "$ASSHRESULT" ]]; then
#							screen -t ${HOSTACTLIST[$SELECTION]} bash -c "bash ${ASSH_SCRIPT_PATH}/assh.bash ${HOSTACTLIST[$SELECTION]}"
#					fi
					# Newtab/Connection condition
					if [[ "$WINDOW_REUSE" = "1" ]]; then
						# This block attempts to load an existing window. If not found, it opens one.
						# In my experience, it will re-open the last window you used with that name (rather than the first, last, etc).
						ASSHRESULT="$(screen -Q select ${HOSTACTLIST[$SELECTION]})"
						if [[ -n "$ASSHRESULT" ]]; then
								screen -t ${HOSTACTLIST[$SELECTION]} bash -c "bash ${ASSH_SCRIPT_PATH}/assh.bash ${HOSTACTLIST[$SELECTION]}"
						fi
					else
						# This block will open a new window every time
						screen -t ${HOSTACTLIST[$SELECTION]} bash -c "bash ${ASSH_SCRIPT_PATH}/assh.bash ${HOSTACTLIST[$SELECTION]}"
					fi
				fi
			;;
#			[0-9]*)
#				# if condition to determine if I need a new screen tab, or just to start RDP
#				if [[ "${OPTIONS[$SELECTION]}" =~ bash$ ]]; then
#					screen -t ${OPTIONS[$SELECTION]} bash -c "bash ${USER_SCRIPT_PATH}/${OPTIONS[$SELECTION]}; echo; echo; read -p 'Continue (end)...'"
#				elif [[ "${OPTIONS[$SELECTION]}" =~ expect$ ]]; then
#					screen -t ${OPTIONS[$SELECTION]} bash -c "expect ${USER_SCRIPT_PATH}/${OPTIONS[$SELECTION]}; echo; echo; read -p 'Continue (end)...'"
#				elif [[ "${OPTIONS[$SELECTION]}" =~ ^rdp ]]; then
#					while [ -z "${ACE_RDP_PASSWORD}" ]; do
#						read -s -p "Enter RDP Password: " ACE_RDP_PASSWORD
#						echo
#					done
#					echo
#					echo "1: 1279x683 2: 2550x1355"
#					read -s -p "Choose Res: " ACE_RDP_RES_SELECT
#					case $ACE_RDP_RES_SELECT in
#						1)
#							ACE_RDP_RES="1279x683"
#						;;
#						2)
#							ACE_RDP_RES="2550x1355"
#						;;
#						*)
#							ACE_RDP_RES="1279x683"
#						;;
#					esac
#					# The hostname it will attempt to connect to is the named entry in ssh/config minus the "rdp_" prefix
#					RDP_CMD="xfreerdp /clipboard /size:${ACE_RDP_RES} /u:${RDP_USERNAME} /p:${ACE_RDP_PASSWORD} /v:$(echo "${OPTIONS[$SELECTION]}" | sed 's/^rdp_//')"
#					echo $RDP_CMD | sed 's/\/p:.*/\/p:******/g'
#					read -p "Continue? (enter|ctrl+c)"
#					screen -t ${OPTIONS[$SELECTION]} bash -c "$RDP_CMD"
#				else
#					# Newtab/Connection condition
#					if [[ "$WINDOW_REUSE" = "1" ]]; then
#						# This block attempts to load an existing window. If not found, it opens one.
#						# In my experience, it will re-open the last window you used with that name (rather than the first, last, etc).
#						ASSHRESULT="$(screen -Q select ${OPTIONS[$SELECTION]})"
#						if [[ -n "$ASSHRESULT" ]]; then
#								screen -t ${OPTIONS[$SELECTION]} bash -c "bash ${ASSH_SCRIPT_PATH}/assh.bash ${OPTIONS[$SELECTION]}"
#						fi
#					else
#						# This block will open a new window every time
#						screen -t ${OPTIONS[$SELECTION]} bash -c "bash ${ASSH_SCRIPT_PATH}/assh.bash ${OPTIONS[$SELECTION]}"
#					fi
#				fi
#			;;
			*)
				echo "Invalid input..."
				read -p ''
		;;
	esac
else
	while true
	do                     
		ssh $1
		echo
		echo '-- connction terminated --'
		read -p 'Reconnect = [enter] | Close = [^c]'
	done
fi
done
