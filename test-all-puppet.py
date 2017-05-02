#! /usr/bin/python3.5

import concurrent.futures
import subprocess


def test_puppet(host):
    return host, subprocess.run('sudo -H FACTER_fqdn="{0}.dtg.cl.cam.ac.uk" '
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

hosts = dig.output.decode("UTF-8").strip().split("\n")

with concurrent.futures.ThreadPoolExecutor() as ex:
    for fs in concurrent.futures.as_completed(ex.map(test_puppet, hosts)):
        name, res = fs.result()
        if res.returncode != 0:
            print(res.output.decode("UTF-8"))
        print("test-puppet ran for {} with rc={}".format(name, res.returncode))
