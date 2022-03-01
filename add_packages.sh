#!/bin/bash

cp -fv libtorrent-rasterbar-2.0.5-update-allocator-sizes-for-boost-1.78.patch /sources
cp -fv networking/netlibs/libtorrent-rasterbar.xml ../blfs_root/blfs-xml/networking/netlibs
cp -fv xsoft/other/qbittorrent.xml ../blfs_root/blfs-xml/xsoft/other
cp -fv xsoft/other/freerdp.xml ../blfs_root/blfs-xml/xsoft/other
cp -fv multimedia/libdriv/libid3tag.xml ../blfs_root/blfs-xml/multimedia/libdriv
cp -fv server/other/minidlna.xml ../blfs_root/blfs-xml/server/other
grep -qF libtorrent-rasterbar.xml ../blfs_root/blfs-xml/networking/netlibs/netlibs.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libtorrent-rasterbar.xml"/>' ../blfs_root/blfs-xml/networking/netlibs/netlibs.xml
grep -qF freerdp.xml ../blfs_root/blfs-xml/xsoft/other/other.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="freerdp.xml"/>' ../blfs_root/blfs-xml/xsoft/other/other.xml
grep -qF qbittorrent.xml ../blfs_root/blfs-xml/xsoft/other/other.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="qbittorrent.xml"/>' ../blfs_root/blfs-xml/xsoft/other/other.xml
grep -qF libid3tag.xml ../blfs_root/blfs-xml/multimedia/libdriv/libdriv.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libid3tag.xml"/>' ../blfs_root/blfs-xml/multimedia/libdriv/libdriv.xml
grep -qF minidlna.xml ../blfs_root/blfs-xml/server/other/other.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="minidlna.xml"/>' ../blfs_root/blfs-xml/server/other/other.xml
grep -qF libtorrent-rasterbar-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY libtorrent-rasterbar-version "2.0.5">' >> ../blfs_root/blfs-xml/packages.ent
grep -qF freerdp-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY freerdp-version "2.6.0">' >> ../blfs_root/blfs-xml/packages.ent
grep -qF qbittorrent-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY qbittorrent-version "4.4.1">' >> ../blfs_root/blfs-xml/packages.ent
grep -qF libid3tag-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY libid3tag-version "0.15.1b">' >> ../blfs_root/blfs-xml/packages.ent
grep -qF minidlna-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY minidlna-version "1.3.0">' >> ../blfs_root/blfs-xml/packages.ent