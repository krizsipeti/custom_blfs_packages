#!/bin/bash
# This script checks and updates the latest versions of the packages

# Function that gets the latest release of a specific package.
# This function works only with packages stored on github.
getLatestGithubRelease()
{
    printf "\nUpdating package: $2\n"
    URL="https://github.com/$1/releases"
    URL=`curl -v --silent $URL 2>&1 | grep 'loading="lazy" src=' | tr '"' '\n' | grep /releases/ -m1`
    URL="https://github.com`curl -v --silent $URL 2>&1 | grep '<a href=' | grep '.tar.' -m1 | tr '"' '\n' | grep /releases/`"
    sed -i -E "s@($2-download-http \"+)(.+\">)@\1$URL\">@" ./$3/$2.xml
    VER=`echo $URL | awk -F/ '{ print $(NF-1) }' | awk -F- '{ print $NF }'`
    sed -i -E "s@($2-version \"+)(.+\">)@\1$VER\">@" add_packages.sh
    echo "Latest version: $VER"
    printf "Found package: $URL\n"
}

#minidlna
DOWNLOAD_URL=`curl -v --silent https://sourceforge.net/projects/minidlna/files/minidlna/ 2>&1 | grep net.sf.files | tr '"' '\n' | grep http -m1`
DOWNLOAD_URL="${DOWNLOAD_URL%/download}"
LATEST_VERSION=`echo $DOWNLOAD_URL | awk -F/ '{ print $NF }'`
sed -i -E "s@(minidlna-version \"+)(.+\">)@\1$LATEST_VERSION\">@" add_packages.sh
DOWNLOAD_URL=$DOWNLOAD_URL/minidlna-$LATEST_VERSION.tar.gz
sed -i -E "s@(minidlna-download-http \"+)(.+\">)@\1$DOWNLOAD_URL\">@" ./server/other/minidlna.xml

#libid3tag
DOWNLOAD_URL=`curl -v --silent https://sourceforge.net/projects/mad/files/libid3tag/ 2>&1 | grep net.sf.files | tr '"' '\n' | grep http -m1`
DOWNLOAD_URL="${DOWNLOAD_URL%/download}"
LATEST_VERSION=`echo $DOWNLOAD_URL | awk -F/ '{ print $NF }'`
sed -i -E "s@(libid3tag-version \"+)(.+\">)@\1$LATEST_VERSION\">@" add_packages.sh
DOWNLOAD_URL=$DOWNLOAD_URL/libid3tag-$LATEST_VERSION.tar.gz
sed -i -E "s@(libid3tag-download-http \"+)(.+\">)@\1$DOWNLOAD_URL\">@" ./multimedia/libdriv/libid3tag.xml

#pkcs11-helper
getLatestGithubRelease OpenSC/pkcs11-helper pkcs11-helper postlfs/security

#QMPlay2
getLatestGithubRelease zaps166/QMPlay2 qmplay2 multimedia/videoutils

#qBittorrent
URL="https://www.qbittorrent.org/download"
DOWNLOAD_URL=`curl -v --silent $URL 2>&1 | tr '"' '\n' | grep '.tar.xz/'`
DOWNLOAD_URL="${DOWNLOAD_URL%/download}"
sed -i -E "s@(qbittorrent-download-http \"+)(.+\">)@\1$DOWNLOAD_URL\">@" ./xsoft/other/qbittorrent.xml
LATEST_VERSION=`echo $DOWNLOAD_URL | tr '-' '\n' | tr '/' '\n' | grep '.tar.xz'`
LATEST_VERSION="${LATEST_VERSION%.tar.xz}"
sed -i -E "s@(qbittorrent-version \"+)(.+\">)@\1$LATEST_VERSION\">@" add_packages.sh

#libtorrent-rasterbar
getLatestGithubRelease arvidn/libtorrent libtorrent-rasterbar networking/netlibs

#SDL2-image
getLatestGithubRelease libsdl-org/SDL_image sdl2-image general/graphlib

#SDL2-ttf
getLatestGithubRelease libsdl-org/SDL_ttf sdl2-ttf general/graphlib


