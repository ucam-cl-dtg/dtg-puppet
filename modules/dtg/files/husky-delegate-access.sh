#!/bin/bash
PATH=/opt/xensource/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
ids=$(xl list | tr -s ' ' | cut -d ' ' -f 2 | tail -n +3)

for id in $ids; do
    sudoers=$(xenstore-read /local/domain/${id}/data/sudoers)
    if [ $? -eq 0 ] ; then
	name=$(xl list $id | cut -d ' ' -f 1 | tail -n 1)
	uuid=$(xe vm-list --minimal params=uuid name-label=$name)
	xe vm-param-clear uuid=$uuid param-name=tags
	for crsid in $sudoers; do
	    echo "Granting $crsid access to $name"
	    xe vm-param-add uuid=$uuid param-name=tags param-key=$crsid
	done
    fi
done
