#!/bin/bash

# Helper function to pach the packages.ent
# Parameters are in this order: major, minor, patch, md5 and full path to packages.ent
patchKernelVersion()
{
    if [ ! -f "$5" ] ; then
        echo "The packages.ent file is not exist or not defined." >&2
        echo "File: $5"
        return 4
    fi

    sed -i -E "s@(<\!ENTITY linux-major-version \"+)(.+\">)@\1$1\">@" "$5"
    sed -i -E "s@(<\!ENTITY linux-minor-version \"+)(.+\">)@\1$2\">@" "$5"    
    sed -i -E "s@(<\!ENTITY linux-md5 \"+)(.+\">)@\1$4\">@" "$5"

    if [ "-" == "$3" ] ; then
        sed -i -E '/<!--/ n; /<\!ENTITY linux-patch-version "/{s/<!E/<!--<!E/g;s/">/">-->/g;}' "$5"
        sed -i -E '/linux-minor-version;">-->/{s/<!--//g;s/-->//g;}' "$5"
        sed -i -E '/<!--/ n; /linux-patch-version;">/{s/<!E/<!--<!E/g;s/;">/;">-->/g;}' "$5"
    else
        sed -i -E '/<!ENTITY linux-patch-version "/{s/<!--//g;s/-->//g;}' "$5"
        sed -i -E "s@(<\!ENTITY linux-patch-version \"+)(.+\">)@\1$3\">@" "$5"
        sed -i -E '/linux-patch-version;">-->/{s/<!--//g;s/-->//g;}' "$5"
        sed -i -E '/<!--/ n; /linux-minor-version;">/{s/<!E/<!--<!E/g;s/;">/;">-->/g;}' "$5"
    fi
}


# Function that createst an fstab based on the incoming folder
createFstab()
{(
    # Get mount info from lsblk output
    local DIR_ROOT
    local DIR_BOOT
    local LSBLK_INFO
    LSBLK_INFO=$(lsblk -l -o MOUNTPOINT,PATH,NAME,PKNAME,PARTUUID,FSTYPE,PTTYPE | sed "/^ /d")

    # Check if we got a mount point as a parameter
    if [ -n "$1" ] ; then
        # In case of an invalid mount point (not existing folder) we return here
        if [ ! -d "$1" ] ; then
            echo "The given mount point is invalid: $1"
            return 1
        fi

        # If a mount point is given then we generate fstab based on that mount point.
        DIR_ROOT="^$1 "
        DIR_BOOT="^$1/boot "
    else
        # No mount point is given. We generate fstab for the current running system.
        DIR_ROOT="^/ "
        DIR_BOOT="^/boot "
    fi

    # Print out the header part of our fstab
    printf "# Begin /etc/fstab\n\n"
    printf '%-45s    %-11s    %-4s    %-16s    %-4s    %-10s\n' "# File system (PARTUUID)" "mount-point" "type" "options" "dump" "fsck"
    printf '#%104s\n\n' "order"

    # Find the root mount point and print out if found
    DIR_ROOT=$(grep "$DIR_ROOT" <<< "$LSBLK_INFO")
    if [ -n "$DIR_ROOT" ] ; then
        printf '%-45s    %-11s    %-4s    %-16s    %-4s    %-10s\n' "PARTUUID=$(awk '{print $5}' <<< "$DIR_ROOT")" / "$(awk '{print $6}' <<< "$DIR_ROOT")" defaults 1 1
    fi

    # Find the boot mount point and print out if found
    DIR_BOOT=$(grep "$DIR_BOOT" <<< "$LSBLK_INFO")
    if [ -n "$DIR_BOOT" ] ; then
        printf '%-45s    %-11s    %-4s    %-16s    %-4s    %-10s\n' "PARTUUID=$(awk '{print $5}' <<< "$DIR_BOOT")" /boot "$(awk '{print $6}' <<< "$DIR_BOOT")" noauto,defaults 0 0
    fi

    # Find the swap partition and print out if found
    local DIR_SWAP
    DIR_SWAP=$(grep "^\[SWAP\] " <<< "$LSBLK_INFO")
    if [ -n "$DIR_SWAP" ] ; then
        printf '%-45s    %-11s    %-4s    %-16s    %-4s    %-10s\n' "PARTUUID=$(awk '{print $5}' <<< "$DIR_SWAP")" swap "$(awk '{print $6}' <<< "$DIR_SWAP")" pri=1 0 0
    fi

    # Print out the closing line of out fstab
    printf "\n# End /etc/fstab\n"    
)}