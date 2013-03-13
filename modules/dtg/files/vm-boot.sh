#! /bin/bash

PUPPETBARE=/etc/puppet-bare
BOOTSTRAP="https://raw.github.com/ucam-cl-dtg/dtg-puppet/master/modules/dtg/files/bootstrap.sh"
AUTHORIZED_KEYS="/root/.ssh/authorized_keys"
DOM0_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAujx2sop6KNPYr6v/IWEpFITi964d89N3uVowvRo3X5f9a7fiquEphaXIvrMoF74TtmWe78NybfPPgKgTdmaBWYxhbykO7aC9QeY+iDcQqKWrLFlBAbqJ6GYJYfiSM0DZbmAXiAuguNhX1LU51zPRVKYf2/yAgCmJv2yammXppwCE+BJvBVqJziy2Cs0PKhI/26Altelc2tH+SMIlF9ZuSKCtAcyMTPQxTVrJ/zilmceh/U3LcLD3OlOD7XfHxUQ+fiH0KZ27dja6mnsb/OAvmqpmD8mYZs2vTUiFRH9V6HmQqQRO82a6XRRK6wHcGnh+J7JW45dO75lmtBElw1djyw== root@husky0.dtg.cl.cam.ac.uk"

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
    chmod +x bootstrap.sh
    ./bootstrap.sh
fi


# if the hostname is puppy* then we want to import dom0's key so
# scripts can SSH in and sort this out. We don't want dom0 to
# monkeysphere. We also generate a new fingerprint

if [ $(echo $HOSTNAME | grep puppy) ]; then
    ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key.pub

    mkdir -p /root/.ssh/
    echo "${DOM0_PUBLIC_KEY}" >> $AUTHORIZED_KEYS

    monkeysphere-authentication update-users
else
    sed -i "\_${DOM0_PUBLIC_KEY}_d" $AUTHORIZED_KEYS
    passwd -l root
    sed -i "s/puppy[0-9]*/$HOSTNAME/g" /etc/hosts
fi
