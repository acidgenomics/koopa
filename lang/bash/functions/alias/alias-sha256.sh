#!/usr/bin/env bash

_koopa_alias_sha256() {
    shasum -a 256 "$@"
}
