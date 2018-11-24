#!/usr/bin/env bash

# https://stackoverflow.com/a/25515370/3911732
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }
