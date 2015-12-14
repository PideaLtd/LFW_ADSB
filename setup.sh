#!/bin/bash

# Check if user is using sudo or is logged in a root.
if [ "$(id -u)" != "0" ]; then
    echo "This script must be ran using sudo or as root."
    exit 1
fi

# Set a variable containing the path to this script.
SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Setup the Netcat script and execute it.
function SetupNetcat() {
    # Set permissions on teh file adsbexchange-maint.sh.
    chmod 755 $SCRIPTPATH/lfw_adsb.sh
    for ((i = 0 ; i <= 20 ; i+=1)); do
        sleep 0.01
        echo $i
    done

    # Add the lfw_adsb.sh script to the file /etc/rc.local.
    if ! grep -Fxq "${SCRIPTPATH}/lfw_adsb.sh &" /etc/rc.local; then
        lnum=($(sed -n '/exit 0/=' /etc/rc.local))
        ((lnum>0)) && sudo sed -i "${lnum[$((${#lnum[@]}-1))]}i ${SCRIPTPATH}/lfw_adb.sh &\n" /etc/rc.local
    fi
    for ((i = 20 ; i <= 40 ; i+=1)); do
        sleep 0.01
        echo $i
    done

    # Kill any currently running instances of the adsbexchange-maint.sh script.
    PIDS=`ps -efww | grep -w "lfw_adsb.sh" | awk -vpid=$$ '$2 != pid { print $2 }'`
    if [ ! -z "$PIDS" ]; then
        sudo kill $PIDS
        for ((i = 40 ; i <= 90 ; i+=1)); do
            sleep 0.1
            echo $i
        done
        sudo kill -9 $PIDS
        echo 90
    else
        for ((i = 40 ; i <= 90 ; i+=1)); do
        sleep 0.1
        echo $i
        done
    fi

    # Execute the lfw_adsb.sh script

    # NOTE:
    # Executing the script here is causing display issues after the script completes.
    # For now I have moved the line which executes adsbexchange-maint.sh after the whiptail guage.

    #sudo $SCRIPTPATH/adsbexchange-maint.sh &
    for ((i = 90 ; i <= 100 ; i+=1)); do
        sleep 0.01
        echo $i
    done

    sleep 2
}

#############
## WHIPTAIL

# Welcome text.
read -d '' WELCOME <<"EOF"
Thanks for choosing to share your data with LowFlyingWales !

Would you like to continue setup?
EOF

# Display the welcome message box.
whiptail --title "LowFlyingWales ADSB network" --yesno "$WELCOME" 16 65
CHOICE=$?

if [ $CHOICE = 1 ]; then
    exit 0
fi

# Setup the Netcat script.
SetupNetcat > >(whiptail --title "LowFlyingWales ADSB Network" --gauge "\nSetting up and executing scripts ..." 7 65 0)
sudo $SCRIPTPATH/lfw_adsb.sh &

# Thank you text.
read -d '' THANKS <<"EOF"
Setup is now complete.

Your feeder should now be feeding data to LowFlyingWales
Thanks again for choosing to share your data with ADS-B Exchange!

EOF

# Display the thank you message box.
whiptail --title "LowFlyingWales ABSD Network" --msgbox "$THANKS" 16 73

exit 0
