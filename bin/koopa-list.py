#!/usr/bin/env python

from os import environ, listdir
from os.path import isfile, join

bin_dir = environ["KOOPA_BIN_DIR"]
scripts = [f for f in listdir(bin_dir) if isfile(join(bin_dir, f))]
scripts = sorted(scripts)
print('\n'.join(scripts)) 
