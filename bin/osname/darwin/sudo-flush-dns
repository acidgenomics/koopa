#!/usr/bin/env bash
set -Eeuxo pipefail

sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
say flushed
