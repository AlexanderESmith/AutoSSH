#!/bin/bash
 
############## START USER CONFIGURABLE ##############
# Where necessary, also update the shebang above.
#       It should be bash, not tsch, csh, or sh.
# The below line should work in most cases. It should
#	be the path to the script. I could code the
#	script to be aware of it's path automatically
#	but... Well I probably will. Someday.
ASSH_SCRIPT_PATH="~/"
# The following line defines the folder that AutoSSH will look for
#	user scripts, so they can be selected from the main menu
USER_SCRIPT_PATH="~/scripts/"
# Set the string below to the header you want to see above the list
RDP_USERNAME='user'
HEADER="ASSH"$'\n'
# Used to hide things the user never needs, but still need to be in the file
# Grep Regex format
SYSTEMFILTER=""
############### END USER CONFIGURABLE ###############

#if [ "$STY" == "" ]; then
#	screen -m "cd ${ASSH_SCRIPT_PATH}; ./assh.bash"
#fi
 
# Used to define something the user specifically wants to see
USERFILTER=""
FANCYDISP=0
clear
while true
do
#	clear
if [[ -z $1 ]]; then
		echo
		COUNT=1
		DISPCOUNT=1
		HOSTDISPLIST=''
		HOSTACTLIST=''
		HOSTS=''
		HOSTSTEMP=''
		METALIST="$(cat ~/.ssh/config ~/.ssh/config.d/* | grep host | grep -v hostname | grep -v "*" \
		| grep -Ev "^#" | awk -F' ' '{print $2}' | sort)"
		METALIST="$METALIST $(ls ${USER_SCRIPT_PATH})"
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
			echo $HEADER | column -t
			echo
			echo "$HOSTDISPLIST" | column
			echo
			if [ "$USERFILTER" ]; then
				echo "Current filter:"
				echo "$USERFILTER"
				echo
			fi
			echo '[blank] - Refresh'
			echo '	 f - [F]ilter (edit current)'
			echo '	ff - [FF]ilter (blank prompt)'
			echo '	 e - [E]dit'
			echo '	 c - Show [c]onfig for listed servers'
			echo "	 d - Toggle fancy [D]isplay (current: $FANCYDISP)"
			echo '	 x - E[x]it'
			echo
			read -p "Select server: " SELECTION
			case $SELECTION in
			'')
				# Catching blank entry. Do nothing, restart loop.
			;;
			c)
				read -p "Showing config lines for listed servers in 'less'; (press enter to continue...)"
				CONFIGLINES="$(echo "")"
				for THISHOST in $HOSTDISPLIST; do
					CONFIGLINES="$CONFIGLINES"$'\n'"$(cat ~/.ssh/config | grep -Ev '^#' | sed -e "/host $THISHOST/,/host /!d" | head -n"-1")"
					#echo '~~~~~~'
				done
				CONFIGLINES="$CONFIGLINES"$'\n'"$(echo "")"
				echo "$CONFIGLINES"$ | grep -Ev '^$|^\s*$' | less
			;;
			e)
				#Exit condition
				vim ~/.ssh/config
			;;
			d)
				if [ "$FANCYDISP" == "0" ]; then
					FANCYDISP=1
				else
					FANCYDISP=0
				fi
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
					screen -t ${HOSTACTLIST[$SELECTION]} bash -c "bash ${USER_SCRIPT_PATH}/${HOSTACTLIST[$SELECTION]}; echo; echo; read -p 'Continue (end)...'"
				elif [[ "${HOSTACTLIST[$SELECTION]}" =~ expect$ ]]; then
					screen -t ${HOSTACTLIST[$SELECTION]} bash -c "expect ${USER_SCRIPT_PATH}/${HOSTACTLIST[$SELECTION]}; echo; echo; read -p 'Continue (end)...'"
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
					# Newtab/Connection condition
					ASSHRESULT="$(screen -Q select ${HOSTACTLIST[$SELECTION]})"
					if [[ -n "$ASSHRESULT" ]]; then
							screen -t ${HOSTACTLIST[$SELECTION]} bash -c "bash ${ASSH_SCRIPT_PATH}/assh.bash ${HOSTACTLIST[$SELECTION]}"
					fi
				fi
			;;
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
