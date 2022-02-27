#! /bin/bash

cp -v libtorrent-rasterbar-2.0.5-update-allocator-sizes-for-boost-1.78.patch /sources
cp -v networking/netlibs/libtorrent-rasterbar.xml ../blfs_root/blfs-xml/networking/netlibs
cp -v xsoft/other/qbittorrent.xml ../blfs_root/blfs-xml/xsoft/other
cp -v multimedia/libdriv/libid3tag.xml ../blfs_root/blfs-xml/multimedia/libdriv
cp -v server/other/minidlna.xml ../blfs_root/blfs-xml/server/other
sed -i '/libtirpc.xml.*/a <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libtorrent-rasterbar.xml"/>' ../blfs_root/blfs-xml/networking/netlibs/netlibs.xml
sed -i '/pidgin.xml.*/a <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="qbittorrent.xml"/>' ../blfs_root/blfs-xml/xsoft/other/other.xml
sed -i '/libmad.xml.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libid3tag.xml"/>' ../blfs_root/blfs-xml/multimedia/libdriv/libdriv.xml
sed -i '/openldap.xml.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="minidlna.xml"/>' ../blfs_root/blfs-xml/server/other/other.xml
sed -i '/libtirpc-version.*/a <!ENTITY libtorrent-rasterbar-version "2.0.5">' ../blfs_root/blfs-xml/packages.ent
sed -i '/pidgin-version.*/a <!ENTITY qbittorrent-version "4.4.1">' ../blfs_root/blfs-xml/packages.ent
sed -i '/libmad-version.*/i <!ENTITY libid3tag-version "0.15.1b">' ../blfs_root/blfs-xml/packages.ent
sed -i '/openldap-version.*/i <!ENTITY minidlna-version "1.3.0">' ../blfs_root/blfs-xml/packages.ent
