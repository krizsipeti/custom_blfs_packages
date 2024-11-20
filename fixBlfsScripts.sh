#!/bin/bash

set -e

if [ -z "$1" ] || [ ! -d "$1" ] ; then
    echo "Script folder not defied or does not exist."
    exit 1
fi

MITKRB=$(find "$1" -type f -iname "*-mitkrb")
if [ -n "$MITKRB" ] ; then
    echo "Patching file $MITKRB..."
    sed -i "/default_realm =/s/$/PKR-LINUX/g;/ = {/s/ =/PKR-LINUX =/g;/\(kdc =\|admin_server =\)/s/PKR-LINUX/pkr-linux/g;/ . =/s/. =/.pkr-linux = PKR-LINUX/g;/host\/PKR-LINUX/s/PKR-LINUX/pkr-linux/g;/kdb5_util create -r/s/-r/-r PKR-LINUX/g" "$MITKRB"
fi

QT6=$(find "$1" -type f -iname "*-qt6")
if [ -n "$QT6" ] ; then
    echo "Patching file $QT6..."
    sed -i "/^export \(C\|CXX\)FLAGS=/s/-O3/-O2/g" "$QT6"
fi
