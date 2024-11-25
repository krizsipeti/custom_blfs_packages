#!/bin/bash

# Function that creates an fstab based on the incoming folder.
# If called without a parameter then it creates one for the current running system.
_create_fstab()
{
    # Check if we got a mount point as a parameter
    local d_root=
    local d_boot=
    if [ -n "$1" ] ; then
        # In case of an invalid mount point or not existing folder we return here
        mountpoint "$1" || return 1

        # If a mount point is given then we generate fstab based on that mount point.
        d_root="$(realpath -sm "$1")"
        d_boot="$(realpath -sm "$1")/boot"
    else
        # No mount point is given. We generate fstab for the current running system.
        d_root="/"
        d_boot="/boot"
    fi

    local gap_size=4 # Num of spaces between columns
    local col_0_name="# "
    local col_1_name="File system (PARTUUID)"
    local col_2_name="mount-point"
    local col_3_name="type"
    local col_4_name="options"
    local col_5_name="dump"
    local col_6_name="fsck-order"
    local col_0_size=${#col_0_name}
    local col_1_size=${#col_1_name}
    local col_2_size=${#col_2_name}
    local col_3_size=${#col_3_name}
    local col_4_size=${#col_4_name}
    local col_5_size=${#col_5_name}
    local col_6_size=${#col_6_name}

    local mount_point=
    local device_path=
    local partition_uuid=
    local file_system_type=
    local options=
    local dump=0
    local fsck=0
    local swap_priority=0
    local values=
    local IFS=$'\n'
    for line in $(lsblk -P -o MOUNTPOINT,PATH,PARTUUID,FSTYPE -x MOUNTPOINT | grep -vE '(MOUNTPOINT="")|(PATH="")|(PARTUUID="")|(FSTYPE="")') ; do
        mount_point=$(awk '{gsub(/MOUNTPOINT=|"/,"",$1); print $1}' <<< "$line")
        device_path=$(awk '{gsub(/PATH=|"/,"",$2); print $2}' <<< "$line")
        partition_uuid=$(awk '{gsub(/"/,"",$3); print $3}' <<< "$line")
        file_system_type=$(awk '{gsub(/FSTYPE=|"/,"",$4); print $4}' <<< "$line")

        if [ -z "$mount_point" ] || [ -z "$device_path" ] || [ -z "$partition_uuid" ] || [ -z "$file_system_type" ]; then
            continue
        fi

        options="defaults"
        dump=0
        fsck=0

        if [ "$mount_point" == "$d_root" ] ; then
            device_path="/"
            dump=1
            fsck=1
        elif [ "$mount_point" == "$d_boot" ] ; then
            device_path="/boot"
            options="noauto,$options"
        elif [ "$mount_point" == "[SWAP]" ] ; then
            device_path="swap"
            swap_priority=$((swap_priority+1))
            options="pri=$swap_priority"
        else
            device_path=${device_path//\/dev\//\/mnt\/}
        fi

        values="$values$partition_uuid $device_path $file_system_type $options $dump $fsck\n"

        if [ ${#partition_uuid} -gt "$col_1_size" ]; then col_1_size=${#partition_uuid} ; fi
        if [ ${#device_path} -gt "$col_2_size" ]; then col_2_size=${#device_path} ; fi
        if [ ${#file_system_type} -gt "$col_3_size" ]; then col_3_size=${#file_system_type} ; fi
        if [ ${#options} -gt "$col_4_size" ]; then col_4_size=${#options} ; fi
        if [ ${#dump} -gt "$col_5_size" ]; then col_5_size=${#dump} ; fi
        if [ ${#fsck} -gt "$col_6_size" ]; then col_6_size=${#fsck} ; fi
    done

    # Print out the header part of our fstab
    local print_format="%-$((col_1_size+gap_size))s%-$((col_2_size+gap_size))s%-$((col_3_size+gap_size))s%-$((col_4_size+gap_size))s%-$((col_5_size+gap_size))s%-$((col_6_size+gap_size))s\n"
    printf "# Begin /etc/fstab\n\n"
    printf "%-${col_0_size}s$print_format\n" "$col_0_name" "$col_1_name" "$col_2_name" "$col_3_name" "$col_4_name" "$col_5_name" "$col_6_name"

    for value in $(echo -e "$values") ; do
        for ((i = 1; i <= col_0_size; i++)) ; do printf " " ; done
        xargs printf "$print_format" <<< "$value"
    done

    # Print out the closing line of fstab
    printf "\n# End /etc/fstab\n"
}