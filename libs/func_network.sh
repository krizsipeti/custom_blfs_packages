#!/bin/bash

# Do network related script patches
# First parameter is the root mount point of the new LFS system
# Second parameter is the user requested BLFS packages
_patch_network_scripts()
{
    # Patch network script
    local dir_commands="$1/jhalfs/lfs-commands"
    local net_script=$(find "$dir_commands" -type f -iname "*-network")
    if [ ! -f "$net_script" ] ; then
        echo "Failed to find the network script file." >&2
        return 1
    fi
    sed -i "s/-static/0/g" "$net_script" &&
    sed -i "/^\(Gateway\)\|\(Address\)\|\(DNS\)\|\(Domains\)=/d" "$net_script" &&
    sed -i "/^\[Network\]/a DHCP=yes" "$net_script" &&
    sed -i "s/^.*PKR-LINUX.local/127.0.0.1 PKR-LINUX.local/" "$net_script"
    if [[ $? -gt 0 ]] ; then
        echo "Failed to patch network script." >&2
        return 1
    fi

    # Check if wpa_supplicant is required and patch its install script if yes
    if [[ $2 == *"wpa_supplicant"* ]] ; then
        sed -i "/^cat > \/etc\/systemd\/network/i cat > /etc/systemd/network/20-wlan0.network << \"EOF\"\n\[Match\]\nName=wlan0\n\n\[Network\]\nDHCP=yes\nEOF" "$net_script" &&
        sed -i "/20-wlan0.network/i mkdir -pv /etc/wpa_supplicant\ncat > /etc/wpa_supplicant/wpa_supplicant-wlan0.conf << \"EOF\"\nnetwork=\{\nssid=\"Telekom-361759\"\n#psk=\"42918671251652357786\"\npsk=ecfb16e5ed6fd6c40782e12a58b47adeefc5dfe2698f43b01f1b2cb799b7b270\n\}\nEOF" "$net_script" &&
        sed -i "/wpa_supplicant@/s/@.*/@wlan0/" "$(find "$1/blfs_root/scripts/" -type f -iname "*-wpa_supplicant")"
        if [[ $? -gt 0 ]] ; then
            echo "Failed to patch wpa_supplicant script." >&2
            return 1
        fi
    fi
}
