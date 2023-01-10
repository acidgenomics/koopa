#!/bin/sh

koopa_alias_sha256() {
    # """
    # sha256 alias.
    # @note Updated 2021-06-08.
    # """
    shasum -a 256 "$@"
}
