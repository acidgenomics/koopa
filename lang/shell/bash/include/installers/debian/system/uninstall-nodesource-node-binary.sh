#!/usr/bin/env bash

main() {
    # """
    # Uninstall NodeSource Node.js binary.
    # @note Updated 2022-04-19.
    # """
    koopa_debian_apt_remove 'nodejs'
    return 0
}
