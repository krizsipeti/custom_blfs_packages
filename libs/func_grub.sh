#!/bin/bash

# Patch grub script
_patch_grub_script()
{
    local dir_commands="$1/jhalfs/lfs-commands"
    local grub_script=$(find "$dir_commands" -type f -iname "1*-grub")
    if [ ! -f "$grub_script" ] ; then
        echo "Cannot find grub script file." >&2
        return 1
    fi

    local kernel_name=$(grep "$grub_script" -e vmlinuz | awk '{gsub("/boot/","",$2); print $2}')
    sed -i "/^cat /i grub-install $(lsblk -l -o MOUNTPOINT,PATH,NAME,PKNAME | grep "^$1 " | awk '{gsub($3,$4,$2); print $2}')\n" "$grub_script" || return 1
    sed -i "/menuentry/a\    set opts=\"net.ifnames=0\ nvidia_drm.modeset=1\"\n    set lnx_root=\"$(lsblk -l -o MOUNTPOINT,PARTUUID | grep "^$1 " | awk '{print $2}')\"\n    set knl_name=\"/$kernel_name\"" "$grub_script" || return 1
    if [ -z "$(lsblk -l -o MOUNTPOINT,PATH | grep "^$1/boot " | awk '{print $2}')" ] ; then
        sed -i 's/knl_name="/knl_name="\/boot/g' "$grub_script" || return 1
    fi
    local boot_fs=$(lsblk -l -o MOUNTPOINT,UUID | grep "^$1/boot " | awk '{print $2}')
    if [ -z "$boot_fs" ] ; then
        boot_fs=$(lsblk -l -o MOUNTPOINT,UUID | grep "^$1 " | awk '{print $2}') || return 1
    fi
    sed -i "/set root=/c\search --set=root --fs-uuid $boot_fs" "$grub_script" || return 1
    sed -i "s/.*gfxpayload=/#&/g" "$grub_script" || return 1
    sed -i "/^ .*linux /c\    linux \${knl_name} root=PARTUUID=\${lnx_root} ro \${opts}" "$grub_script" || return 1
    sed -i '/set timeout/a set color_normal=white/black\nset color_highlight=yellow/black\nset menu_color_normal=light-blue/black\nset menu_color_highlight=yellow/blue' "$grub_script"
}
