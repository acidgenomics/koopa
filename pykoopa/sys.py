#!/usr/bin/env python3

from __future__ import print_function

import os
import subprocess
import sys
import textwrap



# Decompress but keep original compressed file.
# Updated 2019-10-06.
def decompress_but_keep_original(file):
    assert_is_file(file)
    print("Decompressing '" + file + "'.")
    unzip_file = os.path.splitext(file)[0]
    os.system("gunzip -c " + file + " > " + unzip_file)
    return(unzip_file)



# Print to stderr.
#
# See also:
# - 'sys.stderr.write()'.
# - https://stackoverflow.com/questions/5574702
#
# Updated 2019-10-06.
def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)
    sys.exit(1)



# Make a directory recursively and don't error if exists.
#
# See also:
# - 'basejump::initDir()' in R.
# - 'mkdir -p' in shell.
# - https://stackoverflow.com/questions/600268
#
# Updated 2019-10-06.
def init_dir(dir):
    os.makedirs(name=dir, exist_ok=True)



# Paste URL.
#
# Deals with sanitization of trailing slashes automatically.
#
# See also:
# - https://codereview.stackexchange.com/questions/175421/
#
# Updated 2019-10-06.
def paste_url(*args):
    return "/".join(arg.strip("/") for arg in args)



# Download a file using wget.
# If output_file is unset, download to current working directory as basename.
# Updated 2019-10-06.
def wget(url, output_file=None, output_dir=None, decompress=False):
    if not (output_file is None or output_dir is None):
        eprint("Error: Specify 'output_file' or 'output_dir' but not both.")
    if output_file is None:
        output_file = os.path.basename(url)
    if output_dir is None:
        output_dir = os.path.dirname(output_file)
    output_file = os.path.join(output_dir, output_file)
    if os.path.isfile(output_file):
        print("File exists: '" + output_file + "'.")
    else:
        print("Downloading '" + output_file + "'.")
        init_dir(output_dir)
        try:
            subprocess.check_call(["wget", "-O", output_file, url])
        except subprocess.CalledProcessError as e:
            eprint("Failed to download '" + output_file + "'.")
    if decompress is True:
        output_file = decompress_but_keep_original(output_file)
    return(output_file)
