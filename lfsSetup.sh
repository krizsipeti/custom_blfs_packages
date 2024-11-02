#!/bin/bash
# Script that setups LFS installer

set -e

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

# Check if the lfs mount point folder is specified as the first argument
if [ -z "$1" ]
then
    echo "Please specify the lfs mount point folder as the first argument!" >&2
    exit 1
fi

# Check if the lfs folder is exists
if [ ! -d "$1" ]
then
    echo "LFS mount point folder does not exist!" >&2
    exit 2
fi

# Check if jhalfs folder is already exist and delete it if yes
DIR_JHALFS="$1/jhalfs"
if [ -d "$DIR_JHALFS" ]
then
    echo Deleting old jhalfs folder: "$DIR_JHALFS"
    sudo rm -rf "$DIR_JHALFS"
    echo Done!
fi

# Now create the jhalfs folder and book-source sub-folder owned by the current user
DIR_BOOK="$DIR_JHALFS/book-source"
U="$(id -un)" # current user
G="$(id -gn)" # current group
echo Creating jhalfs folder...
sudo install -v -o "$U" -g root -m 1777 -d "$DIR_JHALFS"
sudo install -v -o "$U" -g "$G" -m 1777 -d "$DIR_BOOK"

# Clone the LFS book repository to book-source folder
echo Cloning lfs book sources...
git clone https://git.linuxfromscratch.org/lfs.git "$DIR_BOOK"

# Get the latest kernel version and download link from kernel.org
echo Getting latest kernel from kernel.org...
LATEST_KERNEL_URL="$(curl -v --silent https://www.kernel.org/ 2>&1 | sed -n '/<td id="latest_link">/{n; p}' | cut -d '"' -f 2)"
LATEST_KERNEL_VER="$(cut -d '-' -f 2 <<< "$LATEST_KERNEL_URL" | rev | cut -c8- | rev)"
echo Latest kernel version: "$LATEST_KERNEL_VER"
echo Download URL: "$LATEST_KERNEL_URL"

# Check sources folder existence and create if needed
DIR_SOURCES="$1/sources"
if [ ! -d "$DIR_SOURCES" ] ; then
    sudo install -v -o "$U" -g "$G" -m 1777 -d "$DIR_SOURCES"
else
    sudo chmod -v 1777 "$DIR_SOURCES"
fi

# Download latest kernel if not done yet
KERNEL_FILE_NAME="$(rev <<< "$LATEST_KERNEL_URL" | cut -d '/' -f1 | rev)"
if [ ! -f "$DIR_SOURCES/$KERNEL_FILE_NAME" ] ; then
    echo Downloading kernel tar ball...
    wget -T 30 -t 5 --directory-prefix="$DIR_SOURCES" "$LATEST_KERNEL_URL"
    echo Done!
fi

# Patch packages.ent with latest kernel
MD5_SUM="$(md5sum "$DIR_SOURCES/$KERNEL_FILE_NAME" | cut -d ' ' -f 1)"
NUM_VER_DOTS="$(awk -F. '{print NF-1}' <<< "$LATEST_KERNEL_VER")"
if [ "2" == "$NUM_VER_DOTS" ] ; then
    MAIN_VER="$(awk -F. '{print $(NF-2)}' <<< "$LATEST_KERNEL_VER")"
    MINOR_VER="$(awk -F. '{print $(NF-1)}' <<< "$LATEST_KERNEL_VER")"
    PATCH_VER="$(awk -F. '{print $(NF)}' <<< "$LATEST_KERNEL_VER")"
elif [ "1" == "$NUM_VER_DOTS" ] ; then
    MAIN_VER="$(awk -F. '{print $(NF-1)}' <<< "$LATEST_KERNEL_VER")"
    MINOR_VER="$(awk -F. '{print $(NF)}' <<< "$LATEST_KERNEL_VER")"
    PATCH_VER="-"
else
    echo Invalid count of version dots: "$NUM_VER_DOTS" >&2
    echo Where version number is: "$LATEST_KERNEL_VER" >&2
    exit 3
fi
patchKernelVersion "$MAIN_VER" "$MINOR_VER" "$PATCH_VER" "$MD5_SUM" "$DIR_BOOK/packages.ent"

# Check for the kernel config and try to create it based on a previous one if not found
KERNEL_CONFIG="$HOME/config-$LATEST_KERNEL_VER"
if [ ! -f "$KERNEL_CONFIG" ] ; then
    # Look for older config files in the user's home directory
    CONFIG_FILE=$(find "$HOME" -type f -iwholename "$HOME/config-*")
    if [ -z "$CONFIG_FILE" ] ; then
        echo "Cannot find $KERNEL_CONFIG and also no old configs found to create it."
        exit 4
    fi

    # Select the most recent file based on modification date if there are more
    CONFIG_FILE=$(ls -Art $CONFIG_FILE | tail -n1)
    echo "Using the following old config: $CONFIG_FILE"

    # Extract the latest kernel tar ball and run 'make oldconfig'
    ORIG_FOLDER=$(pwd)
    cd "$DIR_SOURCES"
    if [ -d "linux-$LATEST_KERNEL_VER" ] ; then
        rm -rf "linux-$LATEST_KERNEL_VER"
    fi
    tar -xf "$KERNEL_FILE_NAME"
    cd "linux-$LATEST_KERNEL_VER"
    cp -v "$CONFIG_FILE" .config
    make oldconfig

    # After config created based on old config, copy it back to user's folder
    cp -v .config "$HOME/config-$LATEST_KERNEL_VER"

    # Go back to original folder and delete unpacked linux folder in sources
    cd "$ORIG_FOLDER"
    rm -rf "$DIR_SOURCES/linux-$LATEST_KERNEL_VER"
fi

# Check if setup folder is already exist and delete it if yes
DIR_SETUP="$1/setup"
if [ -d "$DIR_SETUP" ]
then
    echo Deleting old setup folder: "$DIR_SETUP"
    sudo rm -rf "$DIR_SETUP"
    echo Done!
fi

# Now create the setup folder owned by the current user
echo Creating setup folder...
sudo install -v -o "$U" -g "$G" -m 755 -d "$DIR_SETUP"

# Clone the jhalfs repository to setup folder
echo Cloning jhalfs sources...
git clone https://git.linuxfromscratch.org/jhalfs.git "$DIR_SETUP"

# Patch opt_config to use -O3 -pipe -march=native
echo Patching optimization config file...
sed -i -E '/DEF_OPT_MODE=/s/noOpt/O3pipe_march/g' "$DIR_SETUP/optimize/opt_config"

# Copy jhalfs config file and adjust some settings in it
cp -iv lfs_configs/configuration "$DIR_SETUP/"
echo Patching setup configuration file...
FILE_CFG="$DIR_SETUP/configuration"
sed -i -E "\@BUILDDIR=\"xxx\"@s@xxx@$1@g" "$FILE_CFG"
sed -i -E "\@FSTAB=\"xxx\"@s@xxx@/home/$U/fstab@g" "$FILE_CFG"
sed -i -E "\@CONFIG=\"xxx\"@s@xxx@/home/$U/config-$LATEST_KERNEL_VER@g" "$FILE_CFG"
sed -i -E "\@KEYMAP=\"xxx\"@s@xxx@$(localectl | grep Keymap | awk -F' ' '{printf $NF}')@g" "$FILE_CFG"

# Add additional blfs packages to build config if specified any
if [ -n "$2" ] ; then
    SCRIPT_DIR="$DIR_SETUP/common/libs/func_install_blfs"
    LINE_NUMBER=$(grep "$SCRIPT_DIR" -e '$LINE_SUDO' -n -m1 | cut -d: -f1)
    ADDITIONAL_CONFIGS=$(sed 's/,/\n/g' <<< "$2" | sed 's/$/=y/' | sed 's/^/CONFIG_/' | sed '$!s/$/\\/')
    sed -i "$((LINE_NUMBER+1))i$ADDITIONAL_CONFIGS" "$SCRIPT_DIR"
fi

# Enter to setup folder and start installer
cd "$DIR_SETUP"
yes "yes" | ./jhalfs run

# Patch network script
DIR_COMMANDS="$DIR_JHALFS/lfs-commands"
NET_SCRIPT=$(find "$DIR_COMMANDS" -type f -iname "*-network")
if [ -n "$NET_SCRIPT" ] ; then
    sed "s/-static/0/g" "$NET_SCRIPT"
    sed "/^\(Gateway\)\|\(Address\)\|\(DNS\)\|\(Domains\)=/d" "$NET_SCRIPT"
    sed "/^\[Network\]/a DHCP=yes" "$NET_SCRIPT"
    
    if [ "$2" == "*wpa_supplicant*" ] ; then
        sed "/^cat > \/etc\/systemd\/network/i cat > \/etc\/systemd\/network\/20-wlan0.network << \"EOF\"\n\[Match\]\nName=wlan0\n\n\[Network\]\nDHCP=yes\nEOF" "$NET_SCRIPT"
        sed "/20-wlan0.network/i mkdir -pv \/etc\/wpa_supplicant\ncat > \/etc\/wpa_supplicant\/wpa_supplicant-wlan0.conf"
    fi
fi

# Patch LFS kernel script to keep build folder
sed -i "/^rm -rf \$PKGDIR/s/^/#/" "$(find "$DIR_JHALFS/lfs-commands/chapter10/" -type f -iname "*-kernel")"

# Check if wpa_supplicant is required and patch its install script if yes
if [ "$2" == "*wpa_supplicant*" ] ; then
    sed -i "/wpa_supplicant@/s/@.*/@wlan0/" "$(find "$1/blfs_root/scripts/" -type f -iname "*-wpa_supplicant")"
fi