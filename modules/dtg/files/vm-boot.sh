#! /bin/bash
### BEGIN INIT INFO
# Provides:          dtg-vm
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Should-Start:      $named
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: DTG vm properties
# Description:       Apply puppet on VM start
### END INIT INFO

PUPPETBARE=/etc/puppet-bare
BOOTSTRAP="https://raw.github.com/ucam-cl-dtg/dtg-puppet/master/modules/dtg/files/bootstrap.sh"
AUTHORIZED_KEYS="/root/.ssh/authorized_keys"
DOM0_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAujx2sop6KNPYr6v/IWEpFITi964d89N3uVowvRo3X5f9a7fiquEphaXIvrMoF74TtmWe78NybfPPgKgTdmaBWYxhbykO7aC9QeY+iDcQqKWrLFlBAbqJ6GYJYfiSM0DZbmAXiAuguNhX1LU51zPRVKYf2/yAgCmJv2yammXppwCE+BJvBVqJziy2Cs0PKhI/26Altelc2tH+SMIlF9ZuSKCtAcyMTPQxTVrJ/zilmceh/U3LcLD3OlOD7XfHxUQ+fiH0KZ27dja6mnsb/OAvmqpmD8mYZs2vTUiFRH9V6HmQqQRO82a6XRRK6wHcGnh+J7JW45dO75lmtBElw1djyw== root@husky0.dtg.cl.cam.ac.uk"

# if there is a /dev/xvdb without partitions, let's use it

mounted=`mount | grep /dev/xvdb`
if [ -e /dev/xvdb ] && [ ! -e /dev/xvdb1 ] && [[ -z $mounted ]]; then
    echo "Partitioning, and creating filesystem on /dev/xvdb"
    (echo n; echo p; echo 1; echo ; echo; echo w) | fdisk /dev/xvdb
    mkfs.ext4 /dev/xvdb1
    echo "/dev/xvdb1 /local/data ext4 defaults,errors=remount-ro 0 1" >> /etc/fstab
    if [ ! -d /local/data ]; then
	mkdir -p /local/data
    fi
    mount /local/data
fi

# Make sure the machine is up-to-date.
apt-get update
apt-get -y --no-install-recommends dist-upgrade
apt-get -y autoremove

# should we run bootstrap.sh?

if [ ! -d $PUPPETBARE ]; then
    wget ${BOOTSTRAP}
    chmod +x bootstrap.sh
    ./bootstrap.sh
else
    # Get the latest puppet config from code.dtg.
    cd /etc/puppet-bare
    git fetch --quiet git://git.dtg.cl.cam.ac.uk/puppet/dtg-puppet.git
    ./hooks/post-update
fi


# if the hostname is puppy* then we want to import dom0's key so
# scripts can SSH in and sort this out. We don't want dom0 to
# monkeysphere. We also generate a new fingerprint

if [ $(echo $HOSTNAME | grep puppy) ]; then
    rm -rf /etc/ssh/ssh_host_*
    ssh-keygen -t ed25519 -h -f /etc/ssh/ssh_host_ed25519_key < /dev/null
    ssh-keygen -t rsa -b 4096 -h -f /etc/ssh/ssh_host_rsa_key < /dev/null

    mkdir -p /root/.ssh/
    echo "${DOM0_PUBLIC_KEY}" >> $AUTHORIZED_KEYS
    if [  "$(ifconfig eth0 | grep -Eo ..\(\:..\){5})" = "00:16:3e:e8:14:24" ]; then 
	echo dhcp > /etc/hostname
	start hostname
	cd /etc/puppet-bare
	./hooks/post-update
    fi
    monkeysphere-authentication update-users
else
    
    sed -i "\_${DOM0_PUBLIC_KEY}_d" $AUTHORIZED_KEYS
    passwd -l root
    sed -i "s/puppy[0-9]*/$HOSTNAME/g" /etc/hosts
fi
