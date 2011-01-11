#/bin/bash
set -x
splconfigopts=""
path=`pwd`
kernel_ver=`uname -r`

while getopts s:z:l: opt
do case $opt in
	"s")	splconfigopts=$OPTARG;;
	esac
done

#Cloning Repository 
git clone git@github.com:zfs-linux/spl.git
git clone git@github.com:zfs-linux/zfs.git
git clone git@github.com:zfs-linux/lzfs.git
#####

mkdir -p /tmp/logzfs/
touch "/tmp/logzfs/logfile`date +%F`"
logpath="/tmp/logzfs/logfile`date +%F`"

splver="spl"
zfsver="zfs"
lzfsver="lzfs"

cd $path/$splver/ 2> /dev/null
if test $? -ne 0
then
	echo "Error : change directory  "		
	exit -1
fi

git checkout GA-01
git pull

#configuring spl

presize=`ls -s $logpath | cut -d' ' -f1`
./configure $splconfigopts --with-linux=/usr/src/kernels/$kernel_ver/  2>> $logpath
postsize=`ls -s $logpath | cut -d' ' -f1`


if test $presize -ne $postsize
then
	echo  "Error : spl configure error" >> $logpath
	exit -1
fi

# make spl

make 2>> $logpath

if test $? -ne 0
then
	echo  "Error : spl make error" >> $logpath
	exit -1
fi

#make rpms for spl

make rpm 2>> $logpath

if test $? -ne 0
then
        echo  "Error : spl make rpm error" >> $logpath
        exit -1
fi

cd ..

#setting target directories for RPM packages

####################################################

#configuring and compiling zfs
cd $path/$zfsver/ 2>> $logpath
if test $? -ne 0
then
	echo " Error : change directory "
	exit -1
fi

git checkout GA-01
git pull

presize=`ls -s $logpath | cut -d' ' -f1`
./configure --with-linux=/usr/src/kernels/$kernel_ver/ --with-spl=$path/$splver/ 2>> $logpath
postsize=`ls -s $logpath | cut -d' ' -f1`

if test $presize -ne $postsize
then
	echo  "Error : zfs configure error" >> $logpath
	exit -1
fi

#make zfs

make 2>> $logpath 

if test $? -ne 0
then
	echo  "Error : zfs make error" >> $logpath
	exit -1
fi 

#make rpm for zfs

make rpm 2>> $logpath

if test $? -ne 0
then
	echo  "Error : make rpm error for $zfsver" >> $logpath
 	exit -1         
fi

cd ..

#configure lzfs

cd $path/$lzfsver/ 2>> $logpath
if test $? -ne 0
then
        echo " Error : change directory "
        exit -1
fi

git checkout GA-01 
git pull

presize=`ls -s $logpath | cut -d' ' -f1`
./configure --with-linux=/usr/src/kernels/$kernel_ver/ --with-spl=$path/$splver/ --with-zfs=$path/$zfsver/ 2>> $logpath
postsize=`ls -s $logpath | cut -d' ' -f1`

if test $presize -ne $postsize
then
        echo  "Error : lzfs configure error" >> $logpath
        exit -1
fi

#make lzfs

make 2>> $logpath

if test $? -ne 0
then
        echo  "Error : lzfs make error" >> $logpath
        exit -1
fi

#make rpms for lzfs

make rpm 2>> logpath

if test $? -ne 0
then
        echo  "Error : make rpm error for $zfsver" >> $logpath
        exit -1
fi

set +x	
