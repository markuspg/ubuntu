#!/bin/bash -eux

DISK_USAGE_BEFORE_MINIMIZE=$(df -h)

# Remove some packages to get a minimal install
echo "==> Removing all linux kernels except the currrent one"
dpkg --list | awk '{ print $2 }' | grep -e 'linux-\(headers\|image\)-.*[0-9]\($\|-generic\)' | grep -v "$(uname -r | sed 's/-generic//')" | xargs apt-get -y purge
echo "==> Removing linux source"
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge
echo "==> Removing development packages"
dpkg --list | awk '{ print $2 }' | grep -- '-dev$' | xargs apt-get -y purge
echo "==> Removing documentation"
dpkg --list | awk '{ print $2 }' | grep -- '-doc$' | xargs apt-get -y purge
echo "==> Removing obsolete networking components"
apt-get -y purge ppp pppconfig pppoeconf
echo "==> Removing LibreOffice"
apt-get -y purge libreoffice-core libreoffice-calc libreoffice-common libreoffice-draw libreoffice-gtk libreoffice-gnome libreoffice-impress libreoffice-math libreoffice-gtk libreoffice-ogltrans libreoffice-pdfimport libreoffice-writer
echo "==> Removing other oddities"
apt-get -y purge popularity-contest installation-report landscape-common aisleriot gnome-mines gnome-mahjongg gnome-sudoku rhythmbox rhythmbox-data libtotem-plparser-common transmission-common simple-scan thunderbird ubuntu-docs

# Clean up the apt cache
apt-get -y autoremove --purge
apt-get -y autoclean
apt-get -y clean

# Clean up orphaned packages with deborphan
apt-get -y install deborphan
while [ -n "$(deborphan --guess-all --libdevel)" ]; do
  deborphan --guess-all --libdevel | xargs apt-get -y purge
done
apt-get -y purge deborphan dialog

echo "==> Removing man pages"
rm -rf /usr/share/man/*
echo "==> Removing APT files"
find /var/lib/apt -type f | xargs rm -f
echo "==> Removing any docs"
rm -rf /usr/share/doc/*
echo "==> Removing caches"
find /var/cache -type f -exec rm -rf {} \;

echo "==> Disk usage before minimize"
echo "${DISK_USAGE_BEFORE_MINIMIZE}"

echo "==> Disk usage after minimize"
df -h
