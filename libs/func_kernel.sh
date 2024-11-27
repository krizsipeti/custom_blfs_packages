#!/bin/bash

# Check md5 hash format
__is_valid_md5_hash()
{
    case $1 in
      ( *[!0-9A-Fa-f]* | "" ) return 1 ;;
      ( * )                
        case ${#1} in
          ( 32 | 40 ) return 0 ;;
          ( * )       return 1 ;;
        esac
    esac    
  }


# Helper function to pach the packages.ent
# Parameters are in this order: major, minor, patch, md5 and full path to packages.ent
_patch_packages_ent_kernel_version()
{
    # Check parameters
    local number_regex='^[0-9]+$'
    if ! [[ "$1" =~ $number_regex ]] ; then
        echo "Invalid major version: $1" >&2
        return 1
    fi

    if ! [[ "$2" =~ $number_regex ]] ; then
        echo "Invalid minor version: $2" >&2
        return 1
    fi

    if ! [ "$3" == "-" ] && ! [[ "$3" =~ $number_regex ]] ; then
        echo "Invalid patch version: $3" >&2
        return 1
    fi

    __is_valid_md5_hash "$4" || { echo "Invalid md5 hash: $4" >&2 ; return 1 ;}

    if [ ! -f "$5" ] ; then
        echo "Invalid or missing packages.ent file: $5" >&2
        return 1
    fi

    sed -i -E "s@(<\!ENTITY linux-major-version \"+)(.+\">)@\1$1\">@" "$5" &&
    sed -i -E "s@(<\!ENTITY linux-minor-version \"+)(.+\">)@\1$2\">@" "$5" &&
    sed -i -E "s@(<\!ENTITY linux-md5 \"+)(.+\">)@\1$4\">@" "$5"
    if [[ $? -gt 0 ]] ; then return 1; fi

    if [ "-" == "$3" ] ; then
        sed -i -E '/<!--/ n; /<\!ENTITY linux-patch-version "/{s/<!E/<!--<!E/g;s/">/">-->/g;}' "$5" &&
        sed -i -E '/linux-minor-version;">-->/{s/<!--//g;s/-->//g;}' "$5" &&
        sed -i -E '/<!--/ n; /linux-patch-version;">/{s/<!E/<!--<!E/g;s/;">/;">-->/g;}' "$5"
    else
        sed -i -E '/<!ENTITY linux-patch-version "/{s/<!--//g;s/-->//g;}' "$5" &&
        sed -i -E "s@(<\!ENTITY linux-patch-version \"+)(.+\">)@\1$3\">@" "$5" &&
        sed -i -E '/linux-patch-version;">-->/{s/<!--//g;s/-->//g;}' "$5" &&
        sed -i -E '/<!--/ n; /linux-minor-version;">/{s/<!E/<!--<!E/g;s/;">/;">-->/g;}' "$5"
    fi
}


# Determines the download link to the latest stable kernel tar ball.
_get_latest_kernel_url()
{
    local url="$(curl -v --silent https://www.kernel.org/ 2>&1 | sed -n '/<td id="latest_link">/{n; p}' | cut -d '"' -f 2)"
    if ! wget -q --spider "$url" ; then
        echo "Failed to get latest kernel URL." >&2
        return 1
    fi
    echo "$url"
}

# Determines the tarball name of the latest kernel.
_get_latest_kernel_tarball_name()
{
    local url=
    url=$(_get_latest_kernel_url)
    if [[ $? -gt 0 ]] ; then return 1; fi
    local file_name=
    file_name=$(basename "$url")
    if [[ $? -gt 0 ]] ; then return 1 ; else echo "$file_name" ; fi
}


# Determines the version number of the current latest stable kernel
_get_latest_kernel_version()
{
    local url=
    url=$(_get_latest_kernel_url)
    if [[ $? -gt 0 ]] ; then return 1; fi
    echo "$(cut -d '-' -f 2 <<< "$url" | rev | cut -c8- | rev)"
}


# Download latest kernel
# We need here one parameter which is the download folder
_download_latest_kernel()
{
    # Check parameter
    if [ ! -d "$1" ] ; then
        echo "Invalid or missing download folder: $1" >&2
        return 1
    fi

    local url=
    url=$(_get_latest_kernel_url)
    if [[ $? -gt 0 ]] ; then return 1; fi

    # Download only if not there yet
    local file_name="$(basename "$url")"
    if [ ! -f "$1/$file_name" ] ; then
        echo "Downloading kernel tar ball..."
        wget -T 30 -t 5 --directory-prefix="$1" "$url"
        if [[ $? -gt 0 ]] ; then echo "Failed to download kernel: $url" >&2; return 1; fi
        echo "Done!"
    else
        echo "Kernel already downloaded to: $1/$file_name"
    fi
}


# The main script that downloads the latest kernel from the web
# and updates the LFS scripts to use that kernel version for the build.
# It needs one parameter which is the root folder where the LFS will be installed.
_update_lfs_with_latest_kernel()
{
    # Check parameter
    local dir_sources="$1/sources"
    if [ ! -d "$dir_sources" ] ; then
        echo "Invalid or missing folder: $dir_sources" >&2
        return 1
    fi

    # First download the latest kernel
    _download_latest_kernel "$dir_sources" || return 1

    # Calculate md5 sum of kernel file
    local file_name=
    file_name=$(_get_latest_kernel_tarball_name)
    if [[ $? -gt 0 ]] ; then return 1; fi
    local md5_sum=
    md5_sum="$(md5sum "$dir_sources/$file_name" | cut -d ' ' -f 1)"
    if [[ $? -gt 0 ]] ; then echo "Failed to calculate md5sum for: $dir_sources/$file_name" >&2; return 1; fi
    __is_valid_md5_hash "$md5_sum" || { echo "Invalid md5 hash: $md5_sum" >&2; return 1; }

    # Now determine major, minor and patch version numbers
    local major_ver=
    local minor_ver=
    local patch_ver=
    local full_ver=
    full_ver=$(_get_latest_kernel_version)
    if [[ $? -gt 0 ]] ; then return 1; fi
    local num_ver_dots="$(awk -F. '{print NF-1}' <<< "$full_ver")"
    if [ "2" == "$num_ver_dots" ] ; then
        major_ver="$(awk -F. '{print $(NF-2)}' <<< "$full_ver")"
        minor_ver="$(awk -F. '{print $(NF-1)}' <<< "$full_ver")"
        patch_ver="$(awk -F. '{print $(NF)}' <<< "$full_ver")"
    elif [ "1" == "$num_ver_dots" ] ; then
        major_ver="$(awk -F. '{print $(NF-1)}' <<< "$full_ver")"
        minor_ver="$(awk -F. '{print $(NF)}' <<< "$full_ver")"
        patch_ver="-"
    else
        echo Invalid count of version dots: "$num_ver_dots" >&2
        echo Where version number is: "$full_ver" >&2
        exit 1
    fi

    # Now call the script that patches the packages.ent file of the LFS book folder
    _patch_packages_ent_kernel_version "$major_ver" "$minor_ver" "$patch_ver" "$md5_sum" "$1/jhalfs/book-source/packages.ent"
}


# Check and create kernel config if needed
# Needs one parameter which should be the LFS root dir
_create_kernel_config_if_needed()
{
    # First get latest kernel version and file name
    local file_name=
    file_name=$(_get_latest_kernel_tarball_name)
    if [[ $? -gt 0 ]] ; then return 1; fi
    local latest_kernel_ver=
    latest_kernel_ver=$(_get_latest_kernel_version)
    if [[ $? -gt 0 ]] ; then return 1; fi

    # Check if a kernel config is already in the user's home dir for the latest kernel
    # If yes, then we are done
    local kernel_config="$HOME/config-$latest_kernel_ver"
    if [ -f "$kernel_config" ] ; then
        echo "Config found: $kernel_config" >&2
        return 0;
    fi

    # Else look for older config files in the user's home and boot directories
    local config_file=$(find /boot "$HOME" -type f -iwholename "$HOME/config-*" -o -iwholename "/boot/config-*")
    if [ -z "$config_file" ] ; then
        echo "Cannot find $kernel_config and also no old configs found to create it." >&2
        return 1
    fi

    # Select the most recent file based on modification date if there are more
    config_file=$(ls -Art $config_file | tail -n1)
    echo "Using the following old config: $config_file"

    # Check the existence of sources directory
    local dir_sources="$1/sources"
    if [ ! -d "$dir_sources" ] ; then
        echo "Invalid or missing folder: $dir_sources" >&2
        return 1
    fi

    # Extract the latest kernel tar ball and run 'make oldconfig'
    local orig_folder=$(pwd)
    cd "$dir_sources" || return 1
    if [ -d "linux-$latest_kernel_ver" ] ; then
        rm -rf "linux-$latest_kernel_ver" || return 1
    fi
    tar -xf "$file_name" || return 1
    cd "linux-$latest_kernel_ver" || return 1
    cp -v "$config_file" .config || return 1
    make oldconfig || return 1

    # After config created based on old config, copy it back to user's folder
    cp -v .config "$HOME/config-$latest_kernel_ver" || return 1

    # Go back to original folder and delete unpacked linux folder in sources
    cd "$orig_folder"
    rm -rf "$dir_sources/linux-$latest_kernel_ver"
}


# Check for possible needed firmwares defined in kernel config and copy them for the new LFS system
_check_and_copy_needed_firmwares()
{
    # Check parameter
    if [ ! -d "$1" ] ; then
        echo "Invalid or missing folder: $1" >&2
        return 1
    fi

    local latest_kernel_ver=
    latest_kernel_ver=$(_get_latest_kernel_version)
    if [[ $? -gt 0 ]] ; then return 1; fi

    local kernel_config="$HOME/config-$latest_kernel_ver"
    if [ ! -f "$kernel_config" ] ; then
        echo "Cannot find kernel config: $kernel_config" >&2
        return 1;
    fi

    local firmware_files=$(grep "$kernel_config" -e 'CONFIG_EXTRA_FIRMWARE="' | awk -F'"' '{print $2}')
    if [ -n "$firmware_files" ] ; then
        local dir_firmware="/usr/lib/firmware/"
        for firmware in $(tr ' ' '\n' <<< "$firmware_files") ; do
            local dir_firm=$(dirname "$1$dir_firmware$firmware")
            sudo mkdir -pv "$dir_firm" || { echo "Failed to create firmware folder: $dir_firm"; return 1; }
            sudo cp -fv "$dir_firmware$firmware" "$1$dir_firmware$firmware" || { echo "Failed to copy firmware file: $firmware"; return 1; }
        done
    fi
}


# Patch LFS kernel script to keep build folder and add new user
_patch_kernel_script()
{
    # Check parameter
    local dir_commands="$1/jhalfs/lfs-commands"
    if [ ! -d "$dir_commands" ] ; then
        echo "Invalid or missing folder: $dir_commands" >&2
        return 1
    fi

    # Find kernel script
    local kernel_script=$(find "$dir_commands" -type f -iname "*-kernel")
    if [ ! -f "$kernel_script" ] ; then
        echo "Could not find kernel script." >&2
        return 1
    fi

    sed -i "/^rm -rf \$PKGDIR/s/^/#/" "$kernel_script" || { echo "Failed to disable kernel sources deletion." >&2; return 1; }
    sed -i "/^EOF$/a # Add new user\ngroupadd pkr\nuseradd -s /bin/bash -g pkr -m -k /dev/null pkr\nusermod -a -G audio,video,input,systemd-journal pkr\npasswd -s pkr <<< pkr\npasswd -s root <<< root" "$kernel_script"
    if [[ $? -gt 0 ]] ; then
        echo "Failed to add default user creation to kernel script." >&2
        return 1
    fi
}
