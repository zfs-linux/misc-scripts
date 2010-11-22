#!/bin/bash

git clone git://github.com/zfs-linux/zfs.git
git clone git://github.com/zfs-linux/lzfs.git
git clone git://github.com/zfs-linux/spl.git

#copy the ubuntu zfsload script
cp lzfs/etc/init.d/zfsload-ubuntu lzfs/etc/init.d/zfsload
sudo modprobe -r zlib_deflate
for name in zfs
do
echo $name
cd spl
splversion=`awk '/Version/ {print $2}' META`
cd ..
cd $name
version=`awk '/Version/ {print $2}' META`
cd ..
uname=`uname -r`
if [ "$name" = "zfs" ]
then 
sudo mkdir -p /usr/src/spl-$splversion/$uname/module/spl
sudo mkdir -p /usr/src/spl-$splversion/$uname/module/splat
sudo cp spl/module/spl/spl.ko /usr/src/spl-$splversion/$uname/module/spl
sudo cp spl/module/splat/splat.ko /usr/src/spl-$splversion/$uname/module/splat
fi
mv $name $name-$version
tar czf $name-0.5.tar.gz $name-$version
cp $name-0.5.tar.gz $name\_0.5.orig.tar.gz
tar -xzvf $name\_0.5.orig.tar.gz
cd $name-$version

# HERE THIS VARIABLE IS SET MANUALLY IN THE MAKEFILE.IN BUT LATER WE NEED TO SET IT TO THIS SCRIPT.
#export env NORUNCHECK=TRUE
#echo $NORUNCHECK
#printenv | grep CHEC
sudo debuild -i -us -uc
cd ..
mv $name\_0.5-1_amd64.deb $name\_$version-$uname.deb
sudo dpkg -i $name\_$version-$uname.deb
mv $name-$version $name
sudo rm -rf /usr/src/spl-$splversion/$uname/module/spl
sudo rm -rf /usr/src/spl-$splversion/$uname/module/splat
done
rm -rf *.gz *.build *.changes *.dsc
