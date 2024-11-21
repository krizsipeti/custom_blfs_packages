#!/bin/bash

# Check if the lfs mount point folder is specified as the first argument
if [ -z "$1" ]
then
    echo "Please specify the lfs mount point folder as the first argument!" >&2
    exit 1
fi

# Run lfsSetup and reboot if success otherwise power off in 5 minutes
if ! ./lfsSetup.sh "$1" "$2" ; then
    sudo shutdown --poweroff +5
else
    sudo systemctl reboot
fi