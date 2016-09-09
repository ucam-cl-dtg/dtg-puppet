#!/bin/bash

# Test our puppet config against all possible hosts

set -e

cd "$(dirname "$0")"

# Get the list of hostnames by querying the CL DNS and parsing the results
domainNames=$(dig -t AXFR  cl.cam.ac.uk @dns0.cl.cam.ac.uk | grep .dtg.cl.cam.ac.uk | tr -s ' \t' ' ' | egrep '(CNAME)|(A)|(AAAA)' | grep -v RRSIG | grep -v rscfl-vguest | cut -f 1,5 -d ' ' | tr ' ' '\n' | sort | uniq | grep -v '[0-9][0-9][0-9]' | grep -v puppy | grep -v so-22 | grep -v -- '-bmc' | grep dtg.cl.cam.ac.uk | cut -d '.' -f 1)

function test-puppet() {
  # This expects to be run inside the dtg-puppet repository e.g. ~/git/infrastructure/dtg-puppet
  sudo -H FACTER_fqdn="${1}".dtg.cl.cam.ac.uk puppet apply --noop --modulepath=modules --node_name_value="${1}".dtg.cl.cam.ac.uk manifests/nodes/
}

for host in $domainNames
do
  test-puppet "${host}"
done
