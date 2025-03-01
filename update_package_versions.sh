#!/bin/bash
# This script checks and updates the latest versions of the packages

set -e

# Prints which package is about to update.
greetMsg()
{
    printf "\nUpdating package: %s\n" "$1"
}

# Does the actual update of the package with the found version.
updatePkg()
{
    MD5=$(curl -sL "$3" | md5sum | cut -d' ' -f1)
    sed -i -E "s@($1-version \"+)(.+\">)@\1$2\">@" add_packages.sh
    sed -i -E "s@($1-download-http \"+)(.+\">)@\1$3\">@" ./"$4"/"$1".xml
    sed -i -E "s@($1-md5sum *\"+)(.+\">)@\1$MD5\">@" ./"$4"/"$1".xml
    echo "Latest version: $2"
    echo "MD5 sum: $MD5"
    printf "Found package: %s\n" "$3"
}

# Function that gets the latest release of a specific package.
# This function works only with packages stored on github.
getLatestGithubRelease()
{
    greetMsg "$2"
    URL=$(curl -v --silent "https://github.com/$1/releases" 2>&1 | grep 'loading="lazy" src=' | tr '"' '\n' | grep /releases/ -m1)
    URL="https://github.com$(curl -v --silent "$URL" 2>&1 | grep '<a href=' | grep '.tar.' -m1 | tr '"' '\n' | grep "$1")"
    VER=$(echo "$URL" | awk -F/ '{ print $(NF-1) }' | awk -F- '{ print $NF }')
    if [[ $4 ]]; then
        VER=$(echo "$VER" | cut -c"$4")
    fi    
    updatePkg "$2" "$VER" "$URL" "$3" "$MD5"
}

# Function that gets the latest release of a specific package.
# This function works only with packages stored on github.
# It generates a codeload tar.gz download link
getLatestCodeloadRelease()
{
    greetMsg "$2"
    VER=$(curl -v --silent "https://github.com/$1/releases" 2>&1 | grep 'loading="lazy" src=' | tr '"' '\n' | grep /releases/ -m1 | rev | cut -d/ -f1 | rev)
    URL="https://codeload.github.com/$1/tar.gz/refs/tags/$VER"
    updatePkg "$2" "$VER" "$URL" "$3"
}

# Function that gets the latest release of a specific package.
# This function works only with packages stored on sourceforge.
getLatestSourceforgeRelease()
{
    greetMsg "$2"
    URL=$(curl -v --silent "https://sourceforge.net/projects/$1/files/$2/" 2>&1 | grep net.sf.files | tr '"' '\n' | grep http -m1 | rev | cut -c10- | rev)
    VER=$(echo "$URL" | awk -F/ '{ print $NF }')
    if [[ $4 ]]; then
        VER=$(echo "$VER" | cut -c"$4")
    fi
    URL=$URL/$2-$VER.tar.gz
    updatePkg "$2" "$VER" "$URL" "$3"
}

#minidlna
getLatestSourceforgeRelease minidlna minidlna server/other

#libid3tag
getLatestSourceforgeRelease mad libid3tag multimedia/libdriv

#pkcs11-helper
getLatestGithubRelease OpenSC/pkcs11-helper pkcs11-helper postlfs/security

#QMPlay2
getLatestGithubRelease zaps166/QMPlay2 qmplay2 multimedia/videoutils

#qBittorrent
getLatestSourceforgeRelease qbittorrent qbittorrent xsoft/other 13-

#libtorrent-rasterbar
getLatestGithubRelease arvidn/libtorrent libtorrent-rasterbar networking/netlibs 2-

#SDL2-image
getLatestGithubRelease libsdl-org/SDL_image sdl2-image general/graphlib

#SDL2-ttf
getLatestGithubRelease libsdl-org/SDL_ttf sdl2-ttf general/graphlib

#vscode
getLatestCodeloadRelease microsoft/vscode vscode xsoft/other

#cmark
getLatestGithubRelease commonmark/cmark cmark pst/sgml

