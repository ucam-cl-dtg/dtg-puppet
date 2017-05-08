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


def puppet_lint(path, doc=False):
    args = ["puppet-lint", "--fail-on-warnings", "--error-level", "warning"]
    if not doc:
        args += ["--no-documentation-check"]
    args += [path]
    return path, subprocess.run(args,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT)

exit_code = 0

if sys.argv[1] == "--doc":
    doc = True
    mode_txt = "doc"
elif sys.argv[1] == "--err":
    doc = False
    mode_txt = "err"
else:
    print("Error, must specify either --err or --warn")
    sys.exit(1)

with concurrent.futures.ThreadPoolExecutor(max_workers=6) as ex:
    for ftr in concurrent.futures.as_completed([ex.submit(puppet_lint,
                                                          path,
                                                          doc)
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
