#check if directory named modpresets exists and if not create it
presetdir=$(ls -1 | grep modpresets)
if [ "$presetdir" == "modpresets" ]; then
  echo "Preset directory found!"
else
  mkdir modpresets
  echo "Preset directory created!"
fi

#requires xdg-utils and bash!

#jumpto function by Bob Copeland
function jumpto
{
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

#echo help and exit (function)
function echohelp
{
echo -e "\nSyntax: ./ModMan <OPTION>\n \nAvailable Options: \n--remove, -r (Starts Remove mode) \n--new, -n (Starts Adding mode) \n--help, -h (Display this Help message)\n--select, -s, no option (Select a preset) \n"
exit
}

#set colors
NORMCOLOR='\033[0m'
ERRCOLOR='\033[0;31m'

#get current path
currentpath=$(pwd)

#output current path to user
echo ""
echo "Current path appears to be:"
echo $currentpath
echo ""

#check if first option is "remove"
if [ "$1" == "--remove" ] || [ "$1" == "-r" ]; then
	ls -1 -I list.txt $currentpath/modpresets/ > $currentpath/modpresets/list.txt
	startremove=${1:-"startremove"}
	startremove: > /dev/null 2>&1
	echo -e "Preset Removing Mode\n "
	echo "Available Preset Names:"
	cat $currentpath/modpresets/list.txt
	echo -e "\nInsert Preset you want to remove:"
	read toremove
	echo ""
	echo "Are you sure you want to remove Preset '$toremove'? (Y/N)"
	read removeconfirm
	if [ "$removeconfirm" == "Y" ]; then
		if grep -Fxq "$toremove" $currentpath/modpresets/list.txt; then
			echo -e "\nRemoving preset:"
			echo $toremove
			rm -rf $currentpath/modpresets/$toremove
			exit
		elif [ "$removeconfirm" == "N" ]; then
			exit
		else
			echo -e "${ERRCOLOR}ERROR: No Preset Named:"
			echo -e $toremove
			echo -e "${NORMCOLOR}"
			jumpto startremove
		fi
	else
		echo "Removing of preset '$toremove' cancelled"
		exit
	fi

#check if first option is "add"
elif [ "$1" == "--new" ] || [ "$1" == "-n" ]; then
	addstart=${1:-"addstart"}
	addstart: > /dev/null 2>&1
	echo -e "Preset Adding Mode\n "
	echo "Insert new preset name:"
	read toadd
  confirmadd=${1:-"confirmadd"}
	confirmadd: > /dev/null 2>&1
	echo -e "\nCreating Preset named '$toadd'"
	echo -e "\nIs this name correct? (Y/N)(C to cancel)"
	read addconfirm
	if [ "$addconfirm" == "Y" ] || [ "$addconfirm" == "y" ]; then
		mkdir $currentpath/modpresets/$toadd
		echo -e "\nPreset Created! Put mods in $currentpath/modpresets/$toadd"
		exit
	elif [ "$addconfirm" == "C" ] || [ "$addconfirm" == "c" ]; then
		exit
	elif [ "$addconfirm" == "N" ] || [ "$addconfirm" == "n" ]; then
		jumpto addstart
  else
    jumpto confirmadd
	fi

#check if first option is "help"
elif [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
	echohelp

#check if first option is "select" or empty
elif [ "$1" == "--select" ] || [ "$1" == "" ] || [ "$1" == "-s" ]; then
	selectstart=${1:-"selectstart"}
	selectstart: > /dev/null 2>&1
	ls -1 -I list.txt $currentpath/modpresets/ > $currentpath/modpresets/list.txt
	echo "Available Preset Names:"
	cat $currentpath/modpresets/list.txt
	echo ""
	echo "Insert Selected Preset Name"
	read selection
	echo ""
	if grep -Fxq "$selection" $currentpath/modpresets/list.txt; then
		echo "Selected Preset:"
		echo $selection
		echo ""
		rm -rf $currentpath/mods
		cp -rfT $currentpath/modpresets/$selection $currentpath/mods
		echo "Preset Set"
		exit
	else
		echo -e "${ERRCOLOR}ERROR: No Preset Named:"
		echo -e $selection
		echo -e "${NORMCOLOR}"
		jumpto selectstart
	fi

#check if first option is "info"
elif [ "$1" == "--info" ] || [ "$1" == "-i" ]; then
	infostart=${1:-"infostart"}
	infostart: > /dev/null 2>&1
	ls -1 -I list.txt $currentpath/modpresets/ > $currentpath/modpresets/list.txt
	echo "Available Preset Names:"
	cat $currentpath/modpresets/list.txt
	echo ""
	echo "Insert Selected Preset Name"
	read selection
	echo ""
	if grep -Fxq "$selection" $currentpath/modpresets/list.txt; then
		echo "Mod list for preset:"
		echo $selection
		selectionmods=$(ls -1 $currentpath/modpresets/$selection/)
		echo ""
		echo "$selectionmods"
		echo ""
		exit
	else
		echo -e "${ERRCOLOR}ERROR: No Preset Named:"
		echo -e $selection
		echo -e "${NORMCOLOR}"
		jumpto infostart
	fi

#check if first option is "open"
elif [ "$1" == "--open" ] || [ "$1" == "-o" ]; then
	openstart=${1:-"openstart"}
	openstart: > /dev/null 2>&1
	ls -1 -I list.txt $currentpath/modpresets/ > $currentpath/modpresets/list.txt
	echo "Available Preset Names:"
	cat $currentpath/modpresets/list.txt
	echo ""
	echo "Insert Selected Preset Name"
	read selection
	echo ""
	if grep -Fxq "$selection" $currentpath/modpresets/list.txt; then
    echo "opening file manager in preset folder"
    xdg-open $currentpath/modpresets/$selection/
		exit
	else
		echo -e "${ERRCOLOR}ERROR: No Preset Named:"
		echo -e $selection
		echo -e "${NORMCOLOR}"
		jumpto openstart
	fi

#do this if option is incorrect
else
	echo -e "${ERRCOLOR}ERROR: Invalid option: $1"
	echo -e "${NORMCOLOR}"
	echohelp
fi
