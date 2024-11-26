#!/bin/bash

# Create folders and get sources needed for LFS and BLFS installation
_create_folders_and_get_sources()
{
    # Check if the lfs folder is exists
    if [ ! -d "$1" ]
    then
        echo "LFS mount point folder does not exist!" >&2
        return 1
    fi

    # Check if jhalfs folder is already exist and delete it if yes
    local dir_jhalfs="$1/jhalfs"
    if [ -d "$dir_jhalfs" ]
    then
        echo Deleting old jhalfs folder: "$dir_jhalfs"
        sudo rm -rf "$dir_jhalfs" || { echo "Failed to delete folder: $dir_jhalfs" >&2; return 1; }
        echo Done!
    fi

    # Now create the jhalfs folder and book-source sub-folder owned by the current user
    local dir_book="$dir_jhalfs/book-source"
    local u="$(id -un)" # current user
    local g="$(id -gn)" # current group
    echo Creating jhalfs folder...
    sudo install -v -o "$u" -g root -m 1777 -d "$dir_jhalfs" || return 1
    sudo install -v -o "$u" -g "$g" -m 1777 -d "$dir_book" || return 1

    # Clone the LFS book repository to book-source folder
    echo Cloning lfs book sources...
    git clone https://git.linuxfromscratch.org/lfs.git "$dir_book" || return 1

    # Now create the blfs_root folder and blfs-xml sub-folder owned by the current user
    local dir_blfs_book="$1/blfs_root/blfs-xml"
    echo Creating blfs_root folder...
    sudo install -v -o "$u" -g root -m 1777 -d "$1/blfs_root" || return 1
    sudo install -v -o "$u" -g "$g" -m 1777 -d "$dir_blfs_book" || return 1

    # Clone the BLFS book repository to blfs-xml folder
    echo Cloning blfs book sources...
    git clone https://git.linuxfromscratch.org/blfs.git "$dir_blfs_book" || return 1

    # Check sources folder existence and create if needed
    local dir_sources="$1/sources"
    if [ ! -d "$dir_sources" ] ; then
        sudo install -v -o "$u" -g "$g" -m 1777 -d "$dir_sources" || return 1
    else
        sudo chmod -v 1777 "$dir_sources" || return 1
    fi

    # Check if setup folder is already exist and delete it if yes
    local dir_setup="$1/setup"
    if [ -d "$dir_setup" ] ; then
        echo Deleting old setup folder: "$dir_setup"
        sudo rm -rf "$dir_setup" || return 1
        echo Done!
    fi

    # Now create the setup folder owned by the current user
    echo Creating setup folder...
    sudo install -v -o "$u" -g "$g" -m 755 -d "$dir_setup" || return 1

    # Clone the jhalfs repository to setup folder
    echo Cloning jhalfs sources...
    git clone https://git.linuxfromscratch.org/jhalfs.git "$dir_setup"
}


# Patch jhalf sources to our custom needs
# First parameter is the LFS mount point folder
# Second parameter is the (comma separated) list of additional BLFS packages to install with LFS
_patch_jhalfs_sources()
{
    local dir_setup="$1/setup"
    if [ ! -d "$dir_setup" ] ; then
        echo "Invalid folder: $dir_setup"
        return 1
    fi

    # Patch opt_config to use -O3 -pipe -march=native
    echo Patching optimization config file...
    sed -i -E '/DEF_OPT_MODE=/s/noOpt/O3pipe_march/g' "$dir_setup/optimize/opt_config" || { echo "Failed to patch opt_config." >&2; return 1; }

    # Copy jhalfs config file and adjust some settings in it
    local u="$(id -un)" # current user
    local g="$(id -gn)" # current group
    local latest_kernel_ver=
    latest_kernel_ver=$(_get_latest_kernel_version)
    if [[ $? -gt 0 ]] ; then return 1; fi
    cp -iv lfs_configs/configuration "$dir_setup/" || return 1
    echo Patching setup configuration file...
    local file_cfg="$dir_setup/configuration"
    sed -i -E "\@BUILDDIR=\"xxx\"@s@xxx@$1@g" "$file_cfg" &&
    sed -i -E "/^FSTAB=/s/^/#/g" "$file_cfg" &&
    sed -i -E "\@FSTAB=\"xxx\"@s@xxx@/home/$u/fstab@g" "$file_cfg" &&
    sed -i -E "\@CONFIG=\"xxx\"@s@xxx@/home/$g/config-$latest_kernel_ver@g" "$file_cfg" &&
    sed -i -E "\@KEYMAP=\"xxx\"@s@xxx@$(localectl | grep Keymap | awk -F' ' '{printf $NF}')@g" "$file_cfg"
    if [[ $? -gt 0 ]] ; then
        echo "Failed to patch jhalfs configuration file." >&2
        return 1
    fi

    # Add additional blfs packages to build config if specified any
    blfs_packs=postlfs-config-profile,postlfs-config-vimrc
    if [ -n "$2" ] ; then
        blfs_packs="$blfs_packs,$2"
    fi
    local script_dir="$dir_setup/common/libs/func_install_blfs"
    local line_number=$(grep "$script_dir" -e '$LINE_SUDO' -n -m1 | cut -d: -f1)
    additional_configs=$(sed 's/,/\n/g' <<< "$blfs_packs" | sed 's/$/=y/' | sed 's/^/CONFIG_/' | sed '$!s/$/\\/')
    sed -i "$((line_number+1))i$additional_configs" "$script_dir"
    if [[ $? -gt 0 ]] ; then
        echo "Could not add blfs packages to the build config." >&2
        return 1
    fi

    # Patch master.sh to run also the grub config related script
    sed -i '/^ .*10\*grub/s/^/#/g' "$dir_setup/LFS/master.sh"
}