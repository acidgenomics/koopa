#!/bin/sh

koopa_go_packages_prefix() {
    # """
    # Go packages 'GOPATH', for building from source.
    # @note Updated 2021-06-11.
    #
    # This must be different from 'go root' value.
    #
    # @usage koopa_go_packages_prefix [VERSION]
    #
    # @seealso
    # - go help gopath
    # - go env GOPATH
    # - go env GOROOT
    # - https://golang.org/wiki/SettingGOPATH to set a custom GOPATH
    # """
    __koopa_packages_prefix 'go' "$@"
}
