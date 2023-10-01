#!/bin/bash
set -ex

# maintenance.sh
# used to alter the files on the file server
# with commands that are easier to run in/on a pi
# give pi's (all of them) rw access to the nfs shares, mount /boot
# all of them, so best to:
#  shut them all off
#  maintenance.sh
#  boot one pi
#  use it to apt-whatever
#  shut it off
#  normal.sh
# boot all the pies

# this should probably be a .conf and or generated by ansible

dist=bullseye
p=/srv/nfs/rpi/${dist}
boot=${p}/boot
root=${p}/root

# pi overlayroot off
# TODO: use /etc/overlayroot.conf instead of kernel parameter
# sudo mount -o remount,rw /partition/identifier /mount/
# sudo mount -o remount,rw /dev/mmcblk0p2 /media/root-ro
sed -i "/.*/s/overlayroot=tmpfs/overlayroot=/" ${boot}/cmdline.txt

# pi's fstab: (no sd) set nfs mounts / and /boot to automount,rw
sed -i "\@${p}.*\snfs\s@s@\bnoauto\b@auto@" ${root}/etc/fstab
sed -i "\@${p}.*\snfs\s@s@\bro\b@rw@" ${root}/etc/fstab

# server's nfs shares rw
sed -i "/.*/s/ro,/rw,/" /etc/exports
systemctl restart nfs-server.service

