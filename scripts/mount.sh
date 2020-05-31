#!/usr/bin/env sh

mkdir -p $HOME/mounts/win-repos
sudo /usr/bin/vmhgfs-fuse .host:/win-repos $HOME/mounts/win-repos -o subtype=vmhgfs-fuse,allow_other

gpg --import $HOME/mounts/win-repos/gpg-pvt.asc
git secret reveal
