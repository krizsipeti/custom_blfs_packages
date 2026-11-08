#!/bin/bash


_build_glfs()
{
    # First include the needed external script files
    local current_dir="$(dirname "$0")"
    source $current_dir/libs/func_general.sh

    # Turn on multilib and GLFS support for LFS build
    USE_MULTILIB=1
    USE_GLFS=1

    # Run lfsSetup
    ./lfsSetup.sh "$1" "$2"
    if [[ $? -gt 0 ]] ; then
        echo "Failed building LFS system." >&2
        return 1
    fi

    # Setup autologin
    local dir_lfs="$(realpath "$1")"
    _setup_autologin "$dir_lfs" || return 1

    # Create autologin script to run glfs build after reboot
    _create_glfs_builder_script "$dir_lfs" || return 1

    # Reboot system
    sudo systemctl reboot
}

# Shutdown on failure
_build_glfs "$1" "$2" || sudo shutdown --poweroff +5
