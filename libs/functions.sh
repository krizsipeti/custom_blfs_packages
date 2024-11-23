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
    # Check if we got a mount point as a parameter
    local DIR_ROOT
    local DIR_BOOT
    if [ -n "$1" ] ; then
        # In case of an invalid mount point (not existing folder) we return here
        if [ ! -d "$1" ] ; then
            echo "The given mount point is invalid: $1"
            return 1
        fi

        # If a mount point is given then we generate fstab based on that mount point.
        DIR_ROOT="$1 "
        DIR_BOOT="$1/boot "
    else
        # No mount point is given. We generate fstab for the current running system.
        DIR_ROOT="/ "
        DIR_BOOT="/boot "
    fi

    # Print out the header part of our fstab
    printf "# Begin /etc/fstab\n\n"
    printf '%-49s%-15s%-8s%-20s%-8s%-10s\n' "# File system (PARTUUID)" "mount-point" "type" "options" "dump" "fsck"
    printf '#%104s\n\n' "order"

    local PUID
    local FST
    local PAT
    local PF="PARTUUID=%-40s%-15s%-8s%-20s%-8s%-10s\n"
    local PRI=0
    local IFS=$'\n'
    for L in $(lsblk -l -o MOUNTPOINT,PATH,NAME,PKNAME,PARTUUID,FSTYPE | tail -n +2) ; do
        PUID=$(awk '{print $5}' <<< "$L")
        if [ -z "$PUID" ] ; then
            continue
        fi
        FST=$(awk '{print $6}' <<< "$L")
        PAT=$(awk '{print $2}' <<< "$L" | sed "s|/dev/|/mnt/|g")
        if [[ $L == "$DIR_ROOT"* ]] ; then
            printf "$PF" "$PUID" / "$FST" defaults 1 1
        elif [[ $L == "$DIR_BOOT"* ]] ; then
            printf "$PF" "$PUID" /boot "$FST" noauto,defaults 0 0
        elif [[ $L == "[SWAP]"* ]] ; then
            PRI=$((PRI+1))
            printf "$PF" "$PUID" swap "$FST" "pri=$PRI" 0 0
        else
            printf "$PF" "$PUID" "$PAT" "$FST" defaults 0 0
        fi
    done

    # Print out the closing line of fstab
    printf "\n# End /etc/fstab\n"
)}