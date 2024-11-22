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
    local LSBLK_INFO
    LSBLK_INFO=$(lsblk -l -o MOUNTPOINT,PATH,NAME,PKNAME,PARTUUID,FSTYPE,PTTYPE | sed "/^ /d")

    printf "# Begin /etc/fstab\n\n"
    printf '%-45s    %-11s    %-4s    %-16s    %-4s    %-10s\n' "# File system (PARTUUID)" "mount-point" "type" "options" "dump" "fsck"
    printf '#%104s\n\n' "order"

    # Find the root mount point
    local DIR_ROOT
    DIR_ROOT=$(grep "^$1 " <<< "$LSBLK_INFO")
    if [ -z "$DIR_ROOT" ] ; then
        DIR_ROOT=$(grep "^/ " <<< "$LSBLK_INFO")
    fi
    if [ -n "$DIR_ROOT" ] ; then
        printf '%-45s    %-11s    %-4s    %-16s    %-4s    %-10s\n' "PARTUUID=$(awk '{print $5}' <<< "$DIR_ROOT")" / "$(awk '{print $6}' <<< "$DIR_ROOT")" defaults 1 1
    fi

    # Find if there is a separate boot drive
    local DIR_BOOT
    DIR_BOOT=$(grep "^$1/boot " <<< "$LSBLK_INFO")
    if [ -z "$DIR_BOOT" ] && [ -z "$1" ]; then
        DIR_BOOT=$(grep "^/boot " <<< "$LSBLK_INFO")
    fi
    if [ -n "$DIR_BOOT" ] ; then
        printf '%-45s    %-11s    %-4s    %-16s    %-4s    %-10s\n' "PARTUUID=$(awk '{print $5}' <<< "$DIR_BOOT")" /boot "$(awk '{print $6}' <<< "$DIR_BOOT")" noauto,defaults 0 0
    fi

    # Find if there is a swap partition
    local DIR_SWAP
    DIR_SWAP=$(grep "^\[SWAP\] " <<< "$LSBLK_INFO")
    if [ -n "$DIR_SWAP" ] ; then
        printf '%-45s    %-11s    %-4s    %-16s    %-4s    %-10s\n' "PARTUUID=$(awk '{print $5}' <<< "$DIR_SWAP")" swap "$(awk '{print $6}' <<< "$DIR_SWAP")" pri=1 0 0
    fi

    printf "\n# End /etc/fstab\n"    
)}