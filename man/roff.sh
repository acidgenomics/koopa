#!/usr/bin/env bash

ronn --roff *.ronn
mv -fv -t 'man1' *.1
