#!/usr/bin/env python3

import os
import sys


def assert_is_not_file(x):
    if os.path.isfile(x):
        print("Error: File exists: '" + x + "'")
        sys.exit(0)


def assert_is_file(x):
    if not os.path.isfile(x):
        print("Error: Not file: '" + x + "'")
        sys.exit(0)
