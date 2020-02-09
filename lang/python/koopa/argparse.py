#!/usr/bin/env python3
"""
argparse functions.
"""


import argparse
import os


def dir_path(path):
    if os.path.isdir(path):
        return path
    else:
        raise argparse.ArgumentTypeError(
            f"readable_dir:{path} is not a valid path"
        )
