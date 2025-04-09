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
grep -qF sdl2-ttf-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY sdl2-ttf-version "2.24.0">' >> ../blfs_root/blfs-xml/packages.ent

# Add SDL2_image
cp -fv general/graphlib/sdl2-image.xml ../blfs_root/blfs-xml/general/graphlib
grep -qF sdl2-image.xml ../blfs_root/blfs-xml/general/graphlib/graphlib.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="sdl2-image.xml"/>' ../blfs_root/blfs-xml/general/graphlib/graphlib.xml
grep -qF sdl2-image-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY sdl2-image-version "2.8.8">' >> ../blfs_root/blfs-xml/packages.ent

# Add VSCode
cp -fv xsoft/other/vscode.xml ../blfs_root/blfs-xml/xsoft/other
grep -qF vscode.xml ../blfs_root/blfs-xml/xsoft/other/other.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="vscode.xml"/>' ../blfs_root/blfs-xml/xsoft/other/other.xml
grep -qF vscode-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY vscode-version "1.99.1">' >> ../blfs_root/blfs-xml/packages.ent

# Add libcmark
cp -fv pst/sgml/libcmark.xml ../blfs_root/blfs-xml/pst/sgml
grep -qF libcmark.xml ../blfs_root/blfs-xml/pst/sgml/sgml.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libcmark.xml"/>' ../blfs_root/blfs-xml/pst/sgml/sgml.xml
grep -qF libcmark-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY libcmark-version "0.31.1">' >> ../blfs_root/blfs-xml/packages.ent

# Add libebml
cp -fv multimedia/libdriv/libebml.xml ../blfs_root/blfs-xml/multimedia/libdriv
grep -qF libebml.xml ../blfs_root/blfs-xml/multimedia/libdriv/libdriv.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libebml.xml"/>' ../blfs_root/blfs-xml/multimedia/libdriv/libdriv.xml
grep -qF libebml-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY libebml-version "1.4.5">' >> ../blfs_root/blfs-xml/packages.ent

# Add libmatroska
cp -fv multimedia/libdriv/libmatroska.xml ../blfs_root/blfs-xml/multimedia/libdriv
grep -qF libmatroska.xml ../blfs_root/blfs-xml/multimedia/libdriv/libdriv.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libmatroska.xml"/>' ../blfs_root/blfs-xml/multimedia/libdriv/libdriv.xml
grep -qF libmatroska-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY libmatroska-version "1.7.1">' >> ../blfs_root/blfs-xml/packages.ent

# Add mkvtoolnix
cp -fv multimedia/videoutils/mkvtoolnix.xml ../blfs_root/blfs-xml/multimedia/videoutils
grep -qF mkvtoolnix.xml ../blfs_root/blfs-xml/multimedia/videoutils/videoutils.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="mkvtoolnix.xml"/>' ../blfs_root/blfs-xml/multimedia/videoutils/videoutils.xml
grep -qF mkvtoolnix-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY mkvtoolnix-version "90.0">' >> ../blfs_root/blfs-xml/packages.ent

# Add virt-manager
cp -fv postlfs/virtualization/virt-manager.xml ../blfs_root/blfs-xml/postlfs/virtualization
grep -qF virt-manager.xml ../blfs_root/blfs-xml/postlfs/virtualization/virtualization.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="virt-manager.xml"/>' ../blfs_root/blfs-xml/postlfs/virtualization/virtualization.xml
grep -qF virt-manager-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY virt-manager-version "5.0.0">' >> ../blfs_root/blfs-xml/packages.ent

# Add libvirt-python
cp -fv postlfs/virtualization/libvirt-python.xml ../blfs_root/blfs-xml/postlfs/virtualization
grep -qF libvirt-python.xml ../blfs_root/blfs-xml/postlfs/virtualization/virtualization.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libvirt-python.xml"/>' ../blfs_root/blfs-xml/postlfs/virtualization/virtualization.xml
grep -qF libvirt-python-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY libvirt-python-version "11.2.0">' >> ../blfs_root/blfs-xml/packages.ent

# Add libvirt
cp -fv postlfs/virtualization/libvirt.xml ../blfs_root/blfs-xml/postlfs/virtualization
grep -qF libvirt.xml ../blfs_root/blfs-xml/postlfs/virtualization/virtualization.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libvirt.xml"/>' ../blfs_root/blfs-xml/postlfs/virtualization/virtualization.xml
grep -qF libvirt-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY libvirt-version "11.2.0">' >> ../blfs_root/blfs-xml/packages.ent

# Add libosinfo
cp -fv postlfs/virtualization/libosinfo.xml ../blfs_root/blfs-xml/postlfs/virtualization
grep -qF libosinfo.xml ../blfs_root/blfs-xml/postlfs/virtualization/virtualization.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libosinfo.xml"/>' ../blfs_root/blfs-xml/postlfs/virtualization/virtualization.xml
grep -qF libosinfo-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY libosinfo-version "1.12.0">' >> ../blfs_root/blfs-xml/packages.ent

# Add slirp4netns
cp -fv networking/netutils/slirp4netns.xml ../blfs_root/blfs-xml/networking/netutils
grep -qF slirp4netns.xml ../blfs_root/blfs-xml/networking/netutils/netutils.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="slirp4netns.xml"/>' ../blfs_root/blfs-xml/networking/netutils/netutils.xml
grep -qF slirp4netns-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY slirp4netns-version "1.3.2">' >> ../blfs_root/blfs-xml/packages.ent

# Add libvirt-glib
cp -fv postlfs/virtualization/libvirt-glib.xml ../blfs_root/blfs-xml/postlfs/virtualization
grep -qF libvirt-glib.xml ../blfs_root/blfs-xml/postlfs/virtualization/virtualization.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="libvirt-glib.xml"/>' ../blfs_root/blfs-xml/postlfs/virtualization/virtualization.xml
grep -qF libvirt-glib-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY libvirt-glib-version "5.0.0">' >> ../blfs_root/blfs-xml/packages.ent

# Add dnsmasq
cp -fv networking/netutils/dnsmasq.xml ../blfs_root/blfs-xml/networking/netutils
grep -qF dnsmasq.xml ../blfs_root/blfs-xml/networking/netutils/netutils.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="dnsmasq.xml"/>' ../blfs_root/blfs-xml/networking/netutils/netutils.xml
grep -qF dnsmasq-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY dnsmasq-version "2.91">' >> ../blfs_root/blfs-xml/packages.ent

#Add dmidecode
cp -fv general/sysutils/dmidecode.xml ../blfs_root/blfs-xml/general/sysutils
grep -qF dmidecode.xml ../blfs_root/blfs-xml/general/sysutils/sysutils.xml || sed -i '/<\/chapter>.*/i <xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="dmidecode.xml"/>' ../blfs_root/blfs-xml/general/sysutils/sysutils.xml
grep -qF dmidecode-version ../blfs_root/blfs-xml/packages.ent || echo '<!ENTITY dmidecode-version "3.6">' >> ../blfs_root/blfs-xml/packages.ent
