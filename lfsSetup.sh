#!/bin/bash

# Function that setups and builds an LFS system
# First parameter is mandatory and it is the new LFS system's root mount point
_build_lfs()
{
    # Check if the lfs mount point folder is specified as the first argument
    if [ -z "$1" ] ; then
        echo "Please specify the lfs mount point folder as the first argument!" >&2
        return 1
    fi
    local dir_lfs="$(realpath "$1")"

    # First include the needed external script files
    local current_dir="$(dirname "$0")"
    source $current_dir/libs/func_general.sh
    source $current_dir/libs/func_kernel.sh
    source $current_dir/libs/func_network.sh
    source $current_dir/libs/func_fstab.sh
    source $current_dir/libs/func_grub.sh

    # Create folder structure and get LFS and BLFS sources
    _create_folders_and_get_sources "$dir_lfs" || return 1

    # Patch the LFS book's packages.ent with latest kernel
    _update_lfs_with_latest_kernel $dir_lfs || return 1

    # Check for the kernel config and try to create it based on a previous one if not found
    _create_kernel_config_if_needed "$dir_lfs" || return 1

    # Check for possible needed firmwares defined in kernel config
    _check_and_copy_needed_firmwares "$dir_lfs" || return 1

    # Patch jhalfs sources
    _patch_jhalfs_sources "$dir_lfs" "$2" || return 1

    # Enter to setup folder and start installer
    cd "$dir_lfs/setup" || return 1
    yes "yes" | ./jhalfs run
    if [[ $? -gt 0 ]] ; then return 1; fi

    # Patch network script
    _patch_network_scripts "$dir_lfs" "$2" || return 1

    # Patch fstab script
    _patch_fstab $dir_lfs || return 1

    # Patch LFS kernel script to keep build folder and add new user
    _patch_kernel_script "$dir_lfs" || return 1

    # Patch grub script
    _patch_grub_script "$dir_lfs" || return 1

    # Enter to jhalfs folder and start the build
    cd "$dir_lfs/jhalfs" || return 1
    make || return 1

    # Finalize the lfs build
    _finalize_lfs_build "$1"
}

_build_lfs "$1" "$2" || exit 1