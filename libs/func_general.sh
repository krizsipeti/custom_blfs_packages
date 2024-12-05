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

    # Check if jhalfs folder is already exist and delete it if yes
    local dir_blfs="$1/blfs_root"
    if [ -d "$dir_blfs" ]
    then
        echo Deleting old blfs_root folder: "$dir_blfs"
        sudo rm -rf "$dir_blfs" || { echo "Failed to delete folder: $dir_blfs" >&2; return 1; }
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
    local dir_blfs_book="$dir_blfs/blfs-xml"
    echo Creating blfs_root folder...
    sudo install -v -o "$u" -g root -m 1777 -d "$dir_blfs" || return 1
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
    sed -i -E "\@CONFIG=\"xxx\"@s@xxx@/home/$u/config-$latest_kernel_ver@g" "$file_cfg" &&
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


# Final adjustments to the newly created LFS system
_finalize_lfs_build()
{
    # Check parameter
    local dir_lfs="$(realpath "$1")"
    if [ ! -d "$dir_lfs" ] ; then
        echo "Invalid folder: $dir_lfs"
        return 1
    fi

    # Patch the sudoers file
    sudo sed -i "/^root ALL=(ALL:ALL) ALL/a pkr ALL=(ALL:ALL) NOPASSWD: ALL" "$dir_lfs/etc/sudoers" &&

    # Move blfs folder to pkr home folder
    sudo mv -v "$dir_lfs/blfs_root" "$dir_lfs/home/pkr/" &&
    sudo chroot "$dir_lfs" chown -hR pkr:pkr "/home/pkr/blfs_root" &&
    sudo chroot "$dir_lfs" chown -hR pkr:pkr "/var/lib/jhalfs" &&
    sudo sed -i "s|/blfs_root/packdesc.dtd|/home/pkr/blfs_root/packdesc.dtd|g" "$dir_lfs/var/lib/jhalfs/BLFS/instpkg.xml"

    # Copy custom blfs folder to pkr home folder if exist
    if [ ! -d "$HOME/custom_blfs_packages" ] ; then
        return 0
    fi
    sudo cp -rv "$HOME/custom_blfs_packages" "$dir_lfs/home/pkr/" &&
    sudo chroot "$dir_lfs" chown -hR pkr:pkr "/home/pkr/custom_blfs_packages"
}


# Create autologin script to run blfs build after reboot
_setup_autologin()
{
    # Check parameter
    local dir_lfs="$(realpath "$1")"
    if [ ! -d "$dir_lfs" ] ; then
        echo "Invalid folder: $dir_lfs"
        return 1
    fi

    local dir_autologin="$dir_lfs/etc/systemd/system/getty@tty1.service.d"
    sudo mkdir -pv "$dir_autologin" &&
    printf "[Service]\nType=simple\nExecStart=\nExecStart=-/sbin/agetty --autologin pkr --noclear - \$TERM\n" | sudo tee "$dir_autologin/override.conf" > /dev/null
}


# Creates the blfs configuration file to build Xorg with wayland support.
# The only parameter should be the new LFS system's root folder.
_create_blfs_config_xorg()
{
    # Check parameter
    local dir_lfs="$(realpath "$1")"
    if [ ! -d "$dir_lfs" ] ; then
        echo "Invalid folder: $dir_lfs"
        return 1
    fi

    # Create new blfs config
    local dir_blfscfg="$dir_lfs/home/pkr/blfs_root/configuration"
    if [ -f "$dir_blfscfg" ] ; then
        sudo rm -fv "$dir_blfscfg" || return 1
    fi

    cat > "$dir_blfscfg" << EOF
CONFIG_pciutils=y
CONFIG_xinit=y
CONFIG_xorg-evdev-driver=y
CONFIG_xorg-libinput-driver=y
CONFIG_xwayland=y

# Build settings
MS_sendmail=y
MAIL_SERVER="sendmail"
DEPLVL_2=y
optDependency=2
LANGUAGE="hu_HU.UTF-8"
SUDO=y
DEL_LA_FILES=y

# Build Layout
SRC_ARCHIVE="/sources"
BUILD_ROOT="/sources"
BUILD_SUBDIRS=y

# Optimization
JOBS=0
CFG_CFLAGS=" -O3 -pipe -march=native "
CFG_CXXFLAGS=" -O3 -pipe -march=native "
CFG_LDFLAGS="EMPTY"
EOF
}


# Creates the blfs configuration file to build Qt6.
# The only parameter should be the new LFS system's root folder.
_create_blfs_config_qt6()
{
    # Check parameter
    local dir_lfs="$(realpath "$1")"
    if [ ! -d "$dir_lfs" ] ; then
        echo "Invalid folder: $dir_lfs"
        return 1
    fi

    # Create new blfs config
    local dir_blfscfg="$dir_lfs/home/pkr/blfs_root/configuration"
    if [ -f "$dir_blfscfg" ] ; then
        sudo rm -fv "$dir_blfscfg" || return 1
    fi

    cat > "$dir_blfscfg" << EOF
CONFIG_qt6=y

# Build settings
MS_sendmail=y
MAIL_SERVER="sendmail"
DEPLVL_2=y
optDependency=2
LANGUAGE="hu_HU.UTF-8"
SUDO=y
DEL_LA_FILES=y

# Build Layout
SRC_ARCHIVE="/sources"
BUILD_ROOT="/sources"
BUILD_SUBDIRS=y

# Optimization
JOBS=0
CFG_CFLAGS=" -O3 -pipe -march=native "
CFG_CXXFLAGS=" -O3 -pipe -march=native "
CFG_LDFLAGS="EMPTY"
EOF
}


# Creates the blfs configuration file to build LXQt.
# The only parameter should be the new LFS system's root folder.
_create_blfs_config_lxqt()
{
    # Check parameter
    local dir_lfs="$(realpath "$1")"
    if [ ! -d "$dir_lfs" ] ; then
        echo "Invalid folder: $dir_lfs"
        return 1
    fi

    # Create new blfs config
    local dir_blfscfg="$dir_lfs/home/pkr/blfs_root/configuration"
    if [ -f "$dir_blfscfg" ] ; then
        sudo rm -fv "$dir_blfscfg" || return 1
    fi

    cat > "$dir_blfscfg" << EOF
CONFIG_lxqt-menu-data=y
CONFIG_lxqt-panel=y
#CONFIG_lxqt-post-install=y
#CONFIG_lxqt-pre-install=y
CONFIG_lxqt-runner=y
CONFIG_lxqt-session=y
CONFIG_lxqt-sudo=y
CONFIG_lxqt-themes=y
CONFIG_pcmanfm-qt=y
CONFIG_lxqt-notificationd=y
CONFIG_pavucontrol-qt=y
CONFIG_qterminal=y

# Build settings
MS_sendmail=y
MAIL_SERVER="sendmail"
DEPLVL_2=y
optDependency=2
LANGUAGE="hu_HU.UTF-8"
SUDO=y
DEL_LA_FILES=y

# Build Layout
SRC_ARCHIVE="/sources"
BUILD_ROOT="/sources"
BUILD_SUBDIRS=y

# Optimization
JOBS=0
CFG_CFLAGS=" -O3 -pipe -march=native "
CFG_CXXFLAGS=" -O3 -pipe -march=native "
CFG_LDFLAGS="EMPTY"
EOF
}


# Creates the blfs configuration file to build window and display managers.
# For now we use openbox as window manager and sddm as display manager.
# The only parameter should be the new LFS system's root folder.
_create_blfs_config_dm()
{
    # Check parameter
    local dir_lfs="$(realpath "$1")"
    if [ ! -d "$dir_lfs" ] ; then
        echo "Invalid folder: $dir_lfs"
        return 1
    fi

    # Create new blfs config
    local dir_blfscfg="$dir_lfs/home/pkr/blfs_root/configuration"
    if [ -f "$dir_blfscfg" ] ; then
        sudo rm -fv "$dir_blfscfg" || return 1
    fi

    cat > "$dir_blfscfg" << EOF
CONFIG_openbox=y
CONFIG_sddm=y

# Build settings
MS_sendmail=y
MAIL_SERVER="sendmail"
DEPLVL_2=y
optDependency=2
LANGUAGE="hu_HU.UTF-8"
SUDO=y
DEL_LA_FILES=y

# Build Layout
SRC_ARCHIVE="/sources"
BUILD_ROOT="/sources"
BUILD_SUBDIRS=y

# Optimization
JOBS=0
CFG_CFLAGS=" -O3 -pipe -march=native "
CFG_CXXFLAGS=" -O3 -pipe -march=native "
CFG_LDFLAGS="EMPTY"
EOF
}


# Creates script that auto builds the blfs system after successfull lfs build
_create_blfs_builder_script()
{
    # Check parameter
    local dir_lfs="$(realpath "$1")"
    if [ ! -d "$dir_lfs" ] ; then
        echo "Invalid folder: $dir_lfs"
        return 1
    fi

    printf '#!/bin/bash

_build_blfs()
{(
    if ! [ "$USER" == "pkr" ] ; then return 0; fi
    sudo rm -rfv /etc/systemd/system/getty@tty1.service.d
    sudo rm -fv /etc/profile.d/x_build_blfs.sh
    echo "Wait 15 seconds before start to have network ready ..."
    sleep 15
    local dir_home="/home/pkr"
    local dir_blfs_root="$dir_home/blfs_root"
    local dir_lfs_xml="$dir_blfs_root/lfs-xml"
    local dir_blfs_xml="$dir_blfs_root/blfs-xml"
    local dir_blfs_work="$dir_blfs_root/work"
    cd "$dir_lfs_xml"
    git reset --hard
    git clean -xfd
    cd "$dir_blfs_xml"
    git reset --hard
    git clean -xfd
    cd "$dir_blfs_root"
    make clean &&
    make update &&
    sed -i -E "/(=configuration|python3)/s/^/#/g;/=configuration/i\	source /home/pkr/custom_blfs_packages/libs/func_general.sh && _create_blfs_config_xorg /" "$dir_blfs_root/Makefile" &&
    make <<< yes &&
    cd "$dir_blfs_work" &&
    ../gen-makefile.sh &&
    make &&
    cd "$dir_blfs_root" &&
    sed -i -E "s/_create_blfs_config_xorg/_create_blfs_config_qt6/g" "$dir_blfs_root/Makefile" &&
    make <<< yes &&
    cd "$dir_blfs_work" &&
    ../gen-makefile.sh &&
    make &&
    cd "$dir_blfs_root" &&
    sed -i -E "s/_create_blfs_config_qt6/_create_blfs_config_lxqt/g" "$dir_blfs_root/Makefile" &&
    make <<< yes &&
    cd "$dir_blfs_work" &&
    ../gen-makefile.sh &&
    make &&
    cd "$dir_blfs_root" &&
    sed -i -E "s/_create_blfs_config_lxqt/_create_blfs_config_dm/g" "$dir_blfs_root/Makefile" &&
    make <<< yes &&
    cd "$dir_blfs_work" &&
    ../gen-makefile.sh &&
    make
    sudo shutdown --poweroff +1
)}

_build_blfs\n' | sudo tee "$dir_lfs/etc/profile.d/x_build_blfs.sh" > /dev/null
}
