#! /bin/bash

cp -v libtorrent-rasterbar-2.0.5-update-allocator-sizes-for-boost-1.78.patch /sources
cp -v networking/netlibs/libtorrent-rasterbar.xml ../blfs_root/blfs-xml/networking/netlibs
cp -v xsoft/other/qbittorrent.xml ../blfs_root/blfs-xml/xsoft/other
sed -i '/libtirpc.xml.*/a <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libtorrent-rasterbar.xml"/>' ../blfs_root/blfs-xml/networking/netlibs/netlibs.xml
sed -i '/pidgin.xml.*/a <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="qbittorrent.xml"/>' ../blfs_root/blfs-xml/xsoft/other/other.xml
sed -i '/libtirpc-version.*/a <!ENTITY libtorrent-rasterbar-version "2.0.5">' ../blfs_root/blfs-xml/packages.ent
sed -i '/pidgin-version.*/a <!ENTITY qbittorrent-version "4.4.1">' ../blfs_root/blfs-xml/packages.ent
