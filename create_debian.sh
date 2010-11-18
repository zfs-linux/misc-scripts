#!/bin/bash

git clone git://github.com/zfs-linux/zfs.git
git clone git://github.com/zfs-linux/lzfs.git
git clone git://github.com/zfs-linux/spl.git

# copy the ubuntu zfsload script
cp lzfs/scripts/zfsload-ubuntu lzfs/etc/init.d/zfsload
for name in spl zfs lzfs
do
echo $name
cd $name
version=`awk '/Version/ {print $2}' META`
cd ..
mv $name $name-$version
cd $name-$version
uname=`uname -r`
sudo debuild -i -us -uc
cd ..
mv $name\_0.5-1_amd64.deb $name\_$version-$uname.deb
mv $name-$version $name
done
