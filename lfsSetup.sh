#!/bin/bash
# Script that setups LFS installer

# Check if the lfs mount point folder is specified as the first argument
if [ -z "$1" ] ; then
    echo "Please specify the lfs mount point folder as the first argument!" >&2
    exit 1
fi

# Create folder structure and get LFS and BLFS sources
source lib/func_general.sh
_create_folders_and_get_sources "$1" || return 1

# Patch the LFS book's packages.ent with latest kernel
source libs/func_kernel.sh
_update_lfs_with_latest_kernel $1 || return 1

# Check for the kernel config and try to create it based on a previous one if not found
_create_kernel_config_if_needed "$1" || return 1

# Check for possible needed firmwares defined in kernel config
_check_and_copy_needed_firmwares || return 1

# Patch jhalfs sources
_patch_jhalfs_sources "$1" "$2" || return 1

# Enter to setup folder and start installer
cd "$1/setup" || return 1
yes "yes" | ./jhalfs run
if [[ $? -gt 0 ]] ; then return 1; fi

# Patch network script
_patch_network_scripts "$1" || return 1

# Patch fstab script
source libs/func_fstab.sh
_patch_fstab $1 || return 1

# Patch LFS kernel script to keep build folder and add new user
_patch_kernel_script "$1" || return 1

# Patch grub script
_patch_grub_script "$1" || return 1

# Enter to jhalfs folder and start the build
cd "$DIR_JHALFS"
make

# Patch the sudoers file
sudo sed -i "/^root ALL=(ALL:ALL) ALL/a pkr ALL=(ALL:ALL) NOPASSWD: ALL" "$1/etc/sudoers"

# Move blfs folder to pkr home folder
sudo mv -v "$1/blfs_root" "$1/home/pkr/"
sudo chown -hR pkr:pkr "$1/home/pkr/blfs_root"
sudo chown -hR pkr:pkr "$1/var/lib/jhalfs"
sudo sed -i "s|/blfs_root/packdesc.dtd|/home/pkr/blfs_root/packdesc.dtd|g" "$1/var/lib/jhalfs/BLFS/instpkg.xml"

# Create autologin script to run blfs build after reboot
local dir_autologin="$1/etc/systemd/system/getty@tty1.service.d"
sudo mkdir -pv "$dir_autologin"
printf "[Service]\nType=simple\nExecStart=\nExecStart=-/sbin/agetty --autologin pkr %%I 38400 linux\n" | sudo tee "$dir_autologin/override.conf" > /dev/null

cat > "$1/home/pkr/.profile" << EOF
#!/bin/bash
cd "/home/pkr/blfs_root/blfs-xml"
git reset --hard
git clean -xfd
cd "/home/pkr/blfs_root/lfs-xml"
git reset --hard
git clean -xfd
cd "/home/pkr/blfs_root"
make update
. gen_pkg_book.sh <<< yes
cd work
../gen-makefile.sh
make
sudo rm -rfv /etc/systemd/system/getty@tty1.service.d
rm -fv /home/pkr/.profile
sudo systemctl poweroff
EOF

# Create new blfs config
local dir_blfscfg="$1/home/pkr/blfs_root/configuration"
if [ -f "$dir_blfscfg" ] ; then
    sudo rm -fv "$dir_blfscfg"
fi

cat > "$dir_blfscfg" << EOF
CONFIG_pciutils=y
CONFIG_twm=y
CONFIG_xinit=y
CONFIG_xorg-evdev-driver=y
CONFIG_xorg-libinput-driver=y
CONFIG_xwayland=y
CONFIG_sddm=y
CONFIG_openbox=y
CONFIG_lxqt-menu-data=y
CONFIG_lxqt-panel=y
CONFIG_lxqt-post-install=y
CONFIG_lxqt-pre-install=y
CONFIG_lxqt-runner=y
CONFIG_lxqt-session=y
CONFIG_lxqt-sudo=y
CONFIG_lxqt-themes=y
CONFIG_pcmanfm-qt=y
CONFIG_lxqt-notificationd=y
CONFIG_pavucontrol-qt=y
CONFIG_qterminal=y
CONFIG_firefox=y

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
