#/bin/bash

git clone git://github.com/zfs-linux/zfs.git
git clone git://github.com/zfs-linux/lzfs.git
git clone git://github.com/zfs-linux/spl.git

#copy the ubuntu zfsload script
ls /etc/init.d/zfsload 2> /dev/null
if test $? -ne 0
then
	cp -f /etc/init.d/ssh /etc/init.d/zfsload
fi
sudo modprobe -r zlib_deflate

for name in spl zfs lzfs
 do
	echo $name
   	cd spl
   	splversion=`awk '/Version/ {print $2}' META`
	cd ..
   	cd $name
   	version=`awk '/Version/ {print $2}' META`
  	commit_meta_value=`cat META | grep commit | cut -d ' ' -f2`
        commit_text=`cat META | grep commit | cut -d ' ' -f1`
        new_commit=`git log | head -n 1`
        commit_val=`git log | head -n 1 | cut -d ' ' -f2`

      	if [ "$commit_text" = "commit" ]
       	then
               	sed -i "s/$commit_meta_value/$commit_val/g" META 2>> /dev/null
               	if test $? -ne 0
               	then
			echo "error : sed failed"
			exit -1
		fi
	else
		echo $new_commit >> META
	fi
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
	if [ "$name" = "lzfs" ]
   	then
        	echo "in if name = lzfs"
	       	tar czf $name-1.0.tar.gz $name-$version
        	cp $name-1.0.tar.gz $name\_1.0.orig.tar.gz
       		tar -xzvf $name\_1.0.orig.tar.gz
   	else
        	tar czf $name-0.5.tar.gz $name-$version
	       	cp $name-0.5.tar.gz $name\_0.5.orig.tar.gz
        	tar -xzvf $name\_0.5.orig.tar.gz
   	fi
	cd $name-$version

# HERE THIS VARIABLE IS SET MANUALLY IN THE MAKEFILE.IN BUT LATER WE NEED TO SET IT TO THIS SCRIPT.
#export env NORUNCHECK=TRUE
#echo $NORUNCHECK
#printenv | grep CHEC
   	sudo debuild -i -us -uc
	cd ..
   
   	if [ "$name" = "lzfs" ]
	then
        	mv $name\_1.0_amd64.deb $name\_$version-$uname.deb
	elif [ "$name" = "spl" ]
   	then
		mv $name\_0.5-2_amd64.deb $name\_$version-$uname.deb
	else
        	mv $name\_0.5-1_amd64.deb $name\_$version-$uname.deb
   	fi
	sudo dpkg -i $name\_$version-$uname.deb
   	mv $name-$version $name
	sudo rm -rf /usr/src/spl-$splversion/$uname/module/spl
   	sudo rm -rf /usr/src/spl-$splversion/$uname/module/splat
done
rm -rf *.gz *.build *.changes *.dsc
sudo dpkg -r zfs
sudo dpkg -r lzfs
sudo rm /etc/init.d/zfsload
sudo rm /var/lib/dpkg/info/lzfs.*

