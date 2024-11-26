#!/bin/bash

# Do network related script patches
_patch_network_scripts()
{
    # Patch network script
    local dir_commands="$1/jhalfs/lfs-commands"
    net_script=$(find "$dir_commands" -type f -iname "*-network")
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
        sed -i "/20-wlan0.network/i mkdir -pv /etc/wpa_supplicant\ncat > /etc/wpa_supplicant/wpa_supplicant-wlan0.conf << \"EOF\"\nnetwork=\{\nssid=\"T-E797F1\"\n#psk=\"Q2729eq9338qQJ7s\"\npsk=a41c0853c906d7db271a007af55afa9dce2efa8efa994d614b2d7b1d0b38bc72\n\}\nEOF" "$net_script" &&
        sed -i "/wpa_supplicant@/s/@.*/@wlan0/" "$(find "$1/blfs_root/scripts/" -type f -iname "*-wpa_supplicant")"
        if [[ $? -gt 0 ]] ; then
            echo "Failed to patch wpa_supplicant script." >&2
            return 1
        fi
    fi
}