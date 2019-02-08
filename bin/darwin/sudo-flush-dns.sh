#!/usr/bin/env bash
set -Eeuo pipefail

sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
say flushed
