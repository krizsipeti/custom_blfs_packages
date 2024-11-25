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
    if ! [ "$1" =~ $number_regex ] ; then
        echo "Invalid major version: $1" >&2
        return 1
    fi

    if ! [ "$2" =~ $number_regex ] ; then
        echo "Invalid minor version: $2" >&2
        return 1
    fi

    if ! [ "$3" == "-" ] && ! [ "$3" =~ $number_regex ] ; then
        echo "Invalid patch version: $3" >&2
        return 1
    fi

    __is_valid_md5_hash "$4" || { echo "Invalid md5 hash: $4" >&2 ; return 1 ;}

    if [ ! -f "$5" ] ; then
        echo "Invalid or missing packages.ent file: $5" >&2
        return 1
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


# Determines the version number of the current latest stable kernel
_get_latest_kernel_version()
{
    local url=$(_get_latest_kernel_url)
    if [[ $? -gt 0 ]] ; then return 1; fi
    local ver="$(cut -d '-' -f 2 <<< "$url" | rev | cut -c8- | rev)"
    echo $ver
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

    local url=$(_get_latest_kernel_url)
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