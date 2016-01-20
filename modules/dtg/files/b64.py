#! /usr/bin/env python3

import base64
import sys

while(True):
    y = input("")
    print(base64.b64encode(y.encode('ascii')).decode('ascii'), flush=True)
