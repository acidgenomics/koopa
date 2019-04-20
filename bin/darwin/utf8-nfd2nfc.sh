#!/usr/bin/env bash
set -Eeuxo pipefail

convmv -r -f utf8 -t utf8 --nfc --notest .
