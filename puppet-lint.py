#! /usr/bin/python3.5

import concurrent.futures
import subprocess
import sys

try:
    import termcolor
    colored = termcolor.colored
except ImportError:
    colored = lambda t, _: t


paths = ["manifests",
         "modules/bayncore",
         "modules/dtg",
         "modules/exim",
         "modules/gpg",
         "modules/munin",
         "modules/nagios"]


def puppet_lint(path, warn=False):
    args = ["puppet-lint"]
    if warn:
        args += ["--fail-on-warnings", "--error-level", "warning"]
    else:
        args += ["--error-level", "error"]
    args += [path]
    return path, subprocess.run(args,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT)

exit_code = 0

if sys.argv[1] == "--warn":
    warn = True
    mode_txt = "warn"
elif sys.argv[1] == "--err":
    warn = False
    mode_txt = "err"
else:
    print("Error, must specify either --err or --warn")
    sys.exit(1)

with concurrent.futures.ThreadPoolExecutor(max_workers=6) as ex:
    for ftr in concurrent.futures.as_completed([ex.submit(puppet_lint,
                                                          path,
                                                          warn)
                                                for path in paths]):
        path, res = ftr.result()

        if res.returncode == 0:
            print(colored("puppet-lint-{}({}): SUCCESS".format(mode_txt,
                                                               path),
                          "green"))
        else:
            print(colored("puppet-lint-{}({}): FAILURE".format(mode_txt,
                                                               path),
                          "red"))
            exit_code = 1
            print(res.stdout.decode("UTF-8"))
        sys.stdout.flush()
sys.exit(exit_code)
