#! /usr/bin/python3.5

import concurrent.futures
import subprocess
import sys


def test_puppet(host):
    return host, subprocess.run('sudo -H FACTER_fqdn="{0}.dtg.cl.cam.ac.uk" FACTER_hostname="{0}" '
                                'puppet apply --noop --modulepath=modules --node_name_value={0}.dtg.cl.cam.ac.uk '
                                'manifests/nodes/'.format(host),
                                shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

dig = subprocess.run("dig -t AXFR  cl.cam.ac.uk @dns0.cl.cam.ac.uk | "
                     "grep .dtg.cl.cam.ac.uk | "
                     "tr -s ' \t' ' ' | "
                     "egrep '(CNAME)|(A)|(AAAA)' | "
                     "grep -v RRSIG | "
                     "grep -v rscfl-vguest | "
                     "cut -f 1,5 -d ' ' | "
                     "tr ' ' '\n' | "
                     "sort | "
                     "uniq | "
                     "grep -v '[0-9][0-9][0-9]' | "
                     "grep -v puppy | "
                     "grep -v so-22 | "
                     "grep -v -- '-bmc' | "
                     "grep dtg.cl.cam.ac.uk | "
                     "cut -d '.' -f 1",
                     shell=True, stdout=subprocess.PIPE, check=True)

hosts = dig.stdout.decode("UTF-8").strip().split("\n")

exit_code = 0

with concurrent.futures.ThreadPoolExecutor(max_workers=6) as ex:
    for ftr in concurrent.futures.as_completed([ex.submit(test_puppet, host) for host in hosts]):
        name, res = ftr.result()
        if res.returncode != 0:
            exit_code = 1
            print(res.stdout.decode("UTF-8"))
        print("test-puppet ran for {} with rc={}".format(name, res.returncode))
        sys.stdout.flush()

sys.exit(exit_code)
