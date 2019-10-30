#!/bin/sh

tmux -V \
    | head -n 1 \
    | cut -d ' ' -f 2
