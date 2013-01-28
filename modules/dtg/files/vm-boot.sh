#! /bin/bash

PUPPETBARE=/etc/puppet-bare
BOOTSTRAP="https://raw.github.com/ucam-cl-dtg/dtg-puppet/master/modules/dtg/files/bootstrap.sh"

# if there is a /dev/xvdb without partitions, let's use it

if [ -e /dev/xvdb ] && [ ! -e /dev/xvdb1 ]; then
    echo "Partitioning, and creating filesystem on /dev/xvdb"
    (echo n; echo p; echo 1; echo ; echo; echo w) | fdisk /dev/xvdb
    mkfs.ext4 /dev/xvdb1
    echo "/dev/xvdb1 /local/data ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
    if [ ! -d /local/data ]; then
	mkdir -p /local/data
    fi
    mount /local/data
fi

# should we run bootstrap.sh?

if [ ! -d $PUPPETBARE ]; then
    wget ${BOOTSTRAP}
    sed -i '/git config/d' bootstrap.sh
    chmod +x bootstrap.sh
    ./bootstrap.sh
fi
