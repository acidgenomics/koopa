#!/usr/bin/env bash
set -Eeuo pipefail

hostname -I | awk '{print $1}'
