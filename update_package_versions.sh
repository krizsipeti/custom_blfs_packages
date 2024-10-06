#!/bin/bash
# This script checks and updates the latest versions of the packages

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
#DOWNLOAD_URL=`curl -v --silent https://github.com/OpenSC/pkcs11-helper/releases 2>&1 | grep src= | tr '"' '\n' | grep pkcs11-helper- | head -1`
#DOWNLOAD_URL="https://github.com`curl -v --silent $DOWNLOAD_URL 2>&1 | tr '"' '\n' | grep .tar.bz2 -m 1`"
#sed -i -E "s@(pkcs11-helper-download-http \"+)(.+\">)@\1$DOWNLOAD_URL\">@" ./postlfs/security/pkcs11-helper.xml
#LATEST_VERSION=`echo $DOWNLOAD_URL | tr '-' '\n' | tr '/' '\n' | grep '.tar.bz2'`
#LATEST_VERSION="${LATEST_VERSION%.tar.bz2}"
#sed -i -E "s@(pkcs11-helper-version \"+)(.+\">)@\1$LATEST_VERSION\">@" add_packages.sh

#pkcs11-helper
URL="https://github.com/OpenSC/pkcs11-helper/"
LAST_COMMIT=`curl -v --silent $URL 2>&1 | tr '"' '\n' | grep 'spoofed_commit_check' | awk -F/ '{ print $NF }' | cut -c1-7`
LAST_RELEASE=`curl -v --silent $URL 2>&1 | tr '"' '\n' | grep '/releases/tag' | awk -F\/ '{ print $NF }' | cut -c 15-`
LATEST_VERSION="$LAST_RELEASE-$LAST_COMMIT"
sed -i -E "s/(pkcs11-helper-version \"+)(.+\">)/\1$LATEST_VERSION\">/" add_packages.sh
DOWNLOAD_URL="https://github.com/OpenSC/pkcs11-helper/archive/refs/heads/master.zip -O pkcs11-helper-$LATEST_VERSION.zip"
sed -i -E "s@(pkcs11-helper-download-http \"+)(.+\">)@\1$DOWNLOAD_URL\">@" ./postlfs/security/pkcs11-helper.xml

#QMPlay2
URL="https://github.com/zaps166/QMPlay2/"
LAST_COMMIT=`curl -v --silent $URL 2>&1 | tr '"' '\n' | grep 'spoofed_commit_check' | awk -F/ '{ print $NF }' | cut -c1-7`
LAST_RELEASE=`curl -v --silent $URL 2>&1 | tr '"' '\n' | grep '/releases/tag' | awk -F\/ '{ print $NF }'`
LATEST_VERSION="$LAST_RELEASE-$LAST_COMMIT"
sed -i -E "s/(qmplay2-version \"+)(.+\">)/\1$LATEST_VERSION\">/" add_packages.sh
DOWNLOAD_URL="https://github.com/zaps166/QMPlay2/archive/refs/heads/master.zip -O QMPlay2-$LATEST_VERSION.zip"
sed -i -E "s@(qmplay2-download-http \"+)(.+\">)@\1$DOWNLOAD_URL\">@" ./multimedia/videoutils/qmplay2.xml

#qBittorrent
URL="https://www.qbittorrent.org/download"
DOWNLOAD_URL=`curl -v --silent $URL 2>&1 | tr '"' '\n' | grep '.tar.xz/'`
DOWNLOAD_URL="${DOWNLOAD_URL%/download}"
sed -i -E "s@(qbittorrent-download-http \"+)(.+\">)@\1$DOWNLOAD_URL\">@" ./xsoft/other/qbittorrent.xml
LATEST_VERSION=`echo $DOWNLOAD_URL | tr '-' '\n' | tr '/' '\n' | grep '.tar.xz'`
LATEST_VERSION="${LATEST_VERSION%.tar.xz}"
sed -i -E "s@(qbittorrent-version \"+)(.+\">)@\1$LATEST_VERSION\">@" add_packages.sh

#libtorrent-rasterbar
URL="https://github.com/arvidn/libtorrent/"
LAST_COMMIT=`curl -v --silent $URL 2>&1 | tr '"' '\n' | grep 'spoofed_commit_check' | awk -F/ '{ print $NF }' | cut -c1-7`
LAST_RELEASE=`curl -v --silent $URL 2>&1 | tr '"' '\n' | grep '/releases/tag' | awk -F\/ '{ print $NF }' | cut -c 2-`
LATEST_VERSION="$LAST_RELEASE-$LAST_COMMIT"
sed -i -E "s/(libtorrent-rasterbar-version \"+)(.+\">)/\1$LATEST_VERSION\">/" add_packages.sh
DOWNLOAD_URL="https://github.com/arvidn/libtorrent/archive/refs/heads/RC_2_0.zip -O libtorrent-rasterbar-$LATEST_VERSION.zip"
sed -i -E "s@(libtorrent-rasterbar-download-http \"+)(.+\">)@\1$DOWNLOAD_URL\">@" ./networking/netlibs/libtorrent-rasterbar.xml

#SDL2-image
URL="https://github.com/libsdl-org/SDL_image/"
LAST_COMMIT=`curl -v --silent $URL 2>&1 | tr '"' '\n' | grep 'spoofed_commit_check' | awk -F/ '{ print $NF }' | cut -c1-7`
LAST_RELEASE=`curl -v --silent $URL 2>&1 | tr '"' '\n' | grep '/releases/tag' | awk -F\/ '{ print $NF }' | cut -c 9-`
LATEST_VERSION="$LAST_RELEASE-$LAST_COMMIT"
sed -i -E "s/(sdl2-image-version \"+)(.+\">)/\1$LATEST_VERSION\">/" add_packages.sh
DOWNLOAD_URL="https://github.com/libsdl-org/SDL_image/archive/refs/heads/main.zip -O SDL2-image-$LATEST_VERSION.zip"
sed -i -E "s@(sdl2-image-download-http \"+)(.+\">)@\1$DOWNLOAD_URL\">@" ./general/graphlib/sdl2-image.xml

#SDL2-ttf
URL="https://github.com/libsdl-org/SDL_ttf/"
LAST_COMMIT=`curl -v --silent $URL 2>&1 | tr '"' '\n' | grep 'spoofed_commit_check' | awk -F/ '{ print $NF }' | cut -c1-7`
LAST_RELEASE=`curl -v --silent $URL 2>&1 | tr '"' '\n' | grep '/releases/tag' | awk -F\/ '{ print $NF }' | cut -c 9-`
LATEST_VERSION="$LAST_RELEASE-$LAST_COMMIT"
sed -i -E "s/(sdl2-ttf-version \"+)(.+\">)/\1$LATEST_VERSION\">/" add_packages.sh
DOWNLOAD_URL="https://github.com/libsdl-org/SDL_ttf/archive/refs/heads/main.zip -O SDL2-ttf-$LATEST_VERSION.zip"
sed -i -E "s@(sdl2-ttf-download-http \"+)(.+\">)@\1$DOWNLOAD_URL\">@" ./general/graphlib/sdl2-ttf.xml

# Patch scripts.xsl to handle -O parameter in wget urls
sed -i "s/BOOTPACKG=\$(basename \$URL)/BOOTPACKG=\$(basename \$URL | awk -F' ' '{ print \$NF}')/g" ../blfs_root/xsl/scripts.xsl
