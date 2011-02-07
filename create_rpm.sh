#/bin/bash
set -x
splconfigopts=""
path=`pwd`
kernel_ver=`uname -r`

#cloning repo
git clone git@github.com:zfs-linux/spl.git
git clone git@github.com:zfs-linux/zfs.git
git clone git@github.com:zfs-linux/lzfs.git

mkdir -p /tmp/logzfs/
touch "/tmp/logzfs/logfile`date +%F`"
logpath="/tmp/logzfs/logfile`date +%F`"

splver="spl"
zfsver="zfs"
lzfsver="lzfs"

for name in spl zfs lzfs
do
	cd $name 2> /dev/null
	if test $? -ne 0
	then
        	echo "Error : change directory  "               
	        exit -1
	fi

	git checkout GA-01.v02 2> /dev/null
	if test $? -ne 0
        then
                echo "Error : checkout GA-01 failed "               
                exit -1
        fi

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
	
	if [ "$name" = "spl" ]
	then
		presize=`ls -s $logpath | cut -d' ' -f1`
		./configure --disable-debug-kmem --with-linux=/usr/src/kernels/$kernel_ver/  2>> $logpath
		postsize=`ls -s $logpath | cut -d' ' -f1`
		
		if test $presize -ne $postsize
		then
        		echo  "Error : spl configure error" >> $logpath
		        exit -1
		fi
	elif [ "$name" = "zfs" ]
	then
		presize=`ls -s $logpath | cut -d' ' -f1`
		./configure --with-linux=/usr/src/kernels/$kernel_ver/ --with-spl=$path/$splver/ 2>> $logpath
		postsize=`ls -s $logpath | cut -d' ' -f1`

		if test $presize -ne $postsize
		then
        		echo  "Error : zfs configure error" >> $logpath
		        exit -1
		fi
	else 
		presize=`ls -s $logpath | cut -d' ' -f1`
		./configure --with-linux=/usr/src/kernels/$kernel_ver/ --with-spl=$path/$splver/ --with-zfs=$path/$zfsver/ 2>> $logpath
		postsize=`ls -s $logpath | cut -d' ' -f1`

		if test $presize -ne $postsize
		then
		        echo  "Error : lzfs configure error" >> $logpath
		        exit -1
		fi

	fi

	make 2>> $logpath

	if test $? -ne 0
	then
        	echo  "Error : $name make error" >> $logpath
	        exit -1
	fi

	make rpm 2>> logpath

	if test $? -ne 0
	then
        	echo  "Error : make rpm error for $name" >> $logpath
	        exit -1
	fi

	#copying rpm packages	
	
	targetsplpath="$path/rpm_GA-01/$name"
	mkdir -p $targetsplpath
	cp *.rpm $targetsplpath
	cd ..
done

set +x  


		 

