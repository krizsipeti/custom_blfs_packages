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

    local GS=4 # Num of spaces between columns
    local C0N="# "
    local C1N="File system (PARTUUID)"
    local C2N="mount-point"
    local C3N="type"
    local C4N="options"
    local C5N="dump"
    local C6N="fsck-order"
    local C0S=${#C0N}
    local C1S=${#C1N}
    local C2S=${#C2N}
    local C3S=${#C3N}
    local C4S=${#C4N}
    local C5S=${#C5N}
    local C6S=${#C6N}

    local PUID
    local PAT
    local FST
    local OPT
    local DUMP=0
    local FSCK=0
    local PRI=0
    local VALUES
    local IFS=$'\n'
    for L in $(lsblk -l -o MOUNTPOINT,PATH,NAME,PKNAME,PARTUUID,FSTYPE | tail -n +2) ; do
        PUID=$(awk '{print $5}' <<< "$L")
        if [ -z "$PUID" ] ; then
            continue
        fi
        PUID="PARTUUID=$PUID"
        FST=$(awk '{print $6}' <<< "$L")
        OPT="defaults"
        DUMP=0
        FSCK=0

        if [[ $L == "$DIR_ROOT"* ]] ; then
            PAT="/"
            DUMP=1
            FSCK=1
        elif [[ $L == "$DIR_BOOT"* ]] ; then
            PAT="/boot"
            OPT="noauto,$OPT"
        elif [[ $L == "[SWAP]"* ]] ; then
            PAT="swap"
            PRI=$((PRI+1))
            OPT="pri=$PRI"
        else
            PAT=$(awk '{print $2}' <<< "$L" | sed "s|/dev/|/mnt/|g")
        fi

        VALUES="$VALUES$(printf '%s' "$PUID $PAT $FST $OPT $DUMP $FSCK")\n"

        if [ ${#PUID} -gt "$C1S" ]; then C1S=${#PUID} ; fi
        if [ ${#PAT} -gt "$C2S" ]; then C2S=${#PAT} ; fi
        if [ ${#FST} -gt "$C3S" ]; then C3S=${#FST} ; fi
        if [ ${#OPT} -gt "$C4S" ]; then C4S=${#OPT} ; fi
        if [ ${#DUMP} -gt "$C5S" ]; then C5S=${#DUMP} ; fi
        if [ ${#FSCK} -gt "$C6S" ]; then C6S=${#FSCK} ; fi
    done

    # Print out the header part of our fstab
    local FMT="%-$((C1S+GS))s%-$((C2S+GS))s%-$((C3S+GS))s%-$((C4S+GS))s%-$((C5S+GS))s%-$((C6S+GS))s\n"
    printf "# Begin /etc/fstab\n\n"
    printf "%-${C0S}s$FMT\n" "$C0N" "$C1N" "$C2N" "$C3N" "$C4N" "$C5N" "$C6N"

    for V in $(echo -e "$VALUES") ; do
        for ((i = 1; i <= C0S; i++)) ; do printf " " ; done
        xargs printf "$FMT" <<< "$V"
    done

    # Print out the closing line of fstab
    printf "\n# End /etc/fstab\n"
)}