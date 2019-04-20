#!/usr/bin/env bash
set -Eeuxo pipefail

hostname -I | awk '{print $1}'
