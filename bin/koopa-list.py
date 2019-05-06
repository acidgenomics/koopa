#!/usr/bin/env python

from os import environ, listdir
from os.path import isfile, join

bin_dir = environ["KOOPA_BIN_DIR"]

scripts = [f for f in listdir(bin_dir) if isfile(join(bin_dir, f))]
scripts = sorted(scripts)

# Hide invisible files:
# [n for n in os.listdir(...) if not n.startswith(".")]

print('\n'.join(scripts)) 
