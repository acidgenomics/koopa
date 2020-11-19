#!/usr/bin/env python3
"""
URL encode.
Updated 2020-08-17.
"""

import sys

from koopa.strings import url_encode
from koopa.system import koopa_help

koopa_help()


def main():
    """
    URL encode.
    """
    args = sys.argv[1:]
    for arg in args:
        print(url_encode(arg))


main()
