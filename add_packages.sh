#!/bin/bash

# Add libtorrent-rasterbar
cp -fv networking/netlibs/libtorrent-rasterbar.xml ../blfs_root/blfs-xml/networking/netlibs
grep -qF libtorrent-rasterbar.xml ../blfs_root/blfs-xml/networking/netlibs/netlibs.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libtorrent-rasterbar.xml"/>' ../blfs_root/blfs-xml/networking/netlibs/netlibs.xml
grep -qF libtorrent-rasterbar-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY libtorrent-rasterbar-version "2.0.11">' >> ../blfs_root/blfs-xml/packages.ent

# Add qBittorrent
cp -fv xsoft/other/qbittorrent.xml ../blfs_root/blfs-xml/xsoft/other
grep -qF qbittorrent.xml ../blfs_root/blfs-xml/xsoft/other/other.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="qbittorrent.xml"/>' ../blfs_root/blfs-xml/xsoft/other/other.xml
grep -qF qbittorrent-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY qbittorrent-version "5.0.4">' >> ../blfs_root/blfs-xml/packages.ent

# Add pkcs11-helper
cp -fv postlfs/security/pkcs11-helper.xml ../blfs_root/blfs-xml/postlfs/security
grep -qF pkcs11-helper.xml ../blfs_root/blfs-xml/postlfs/security/security.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="pkcs11-helper.xml"/>' ../blfs_root/blfs-xml/postlfs/security/security.xml
grep -qF pkcs11-helper-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY pkcs11-helper-version "1.30.0">' >> ../blfs_root/blfs-xml/packages.ent

# Add libid3tag
cp -fv multimedia/libdriv/libid3tag.xml ../blfs_root/blfs-xml/multimedia/libdriv
grep -qF libid3tag.xml ../blfs_root/blfs-xml/multimedia/libdriv/libdriv.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libid3tag.xml"/>' ../blfs_root/blfs-xml/multimedia/libdriv/libdriv.xml
grep -qF libid3tag-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY libid3tag-version "0.15.1b">' >> ../blfs_root/blfs-xml/packages.ent

# Add minidlna
cp -fv server/other/minidlna.xml ../blfs_root/blfs-xml/server/other
grep -qF minidlna.xml ../blfs_root/blfs-xml/server/other/other.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="minidlna.xml"/>' ../blfs_root/blfs-xml/server/other/other.xml
grep -qF minidlna-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY minidlna-version "1.3.3">' >> ../blfs_root/blfs-xml/packages.ent

# Add QMPlay2
cp -fv multimedia/videoutils/qmplay2.xml ../blfs_root/blfs-xml/multimedia/videoutils
grep -qF qmplay2.xml ../blfs_root/blfs-xml/multimedia/videoutils/videoutils.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="qmplay2.xml"/>' ../blfs_root/blfs-xml/multimedia/videoutils/videoutils.xml
grep -qF qmplay2-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY qmplay2-version "25.01.19">' >> ../blfs_root/blfs-xml/packages.ent

# Add SDL2_ttf
cp -fv general/graphlib/sdl2-ttf.xml ../blfs_root/blfs-xml/general/graphlib
grep -qF sdl2-ttf.xml ../blfs_root/blfs-xml/general/graphlib/graphlib.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="sdl2-ttf.xml"/>' ../blfs_root/blfs-xml/general/graphlib/graphlib.xml
grep -qF sdl2-ttf-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY sdl2-ttf-version "3.1.2">' >> ../blfs_root/blfs-xml/packages.ent

# Add SDL2_image
cp -fv general/graphlib/sdl2-image.xml ../blfs_root/blfs-xml/general/graphlib
grep -qF sdl2-image.xml ../blfs_root/blfs-xml/general/graphlib/graphlib.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="sdl2-image.xml"/>' ../blfs_root/blfs-xml/general/graphlib/graphlib.xml
grep -qF sdl2-image-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY sdl2-image-version "2.8.8">' >> ../blfs_root/blfs-xml/packages.ent

# Add VSCode
cp -fv xsoft/other/vscode.xml ../blfs_root/blfs-xml/xsoft/other
grep -qF vscode.xml ../blfs_root/blfs-xml/xsoft/other/other.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="vscode.xml"/>' ../blfs_root/blfs-xml/xsoft/other/other.xml
grep -qF vscode-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY vscode-version "1.98.0">' >> ../blfs_root/blfs-xml/packages.ent

# Add cmark
cp -fv pst/sgml/cmark.xml ../blfs_root/blfs-xml/pst/sgml
grep -qF cmark.xml ../blfs_root/blfs-xml/pst/sgml/sgml.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="cmark.xml"/>' ../blfs_root/blfs-xml/pst/sgml/sgml.xml
grep -qF cmark-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY cmark-version "tags">' >> ../blfs_root/blfs-xml/packages.ent