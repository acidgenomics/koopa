#!/usr/bin/env python3
"""
Assertive checks.
"""

import os
import sys


def assert_is_not_file(path):
    """
    Does the input not contain a file?
    Updated 2019-10-07.
    """
    if os.path.isfile(path):
        print("Error: File exists: '" + path + "'")
        sys.exit(0)


def assert_is_file(path):
    """
    Does the input contain a file?
    Updated 2019-10-07.
    """
    if not os.path.isfile(path):
        print("Error: Not file: '" + path + "'")
        sys.exit(0)
