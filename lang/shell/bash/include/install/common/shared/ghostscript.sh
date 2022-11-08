#!/usr/bin/env bash

# FIXME Need to rework to build from source, to support 10.0.0.
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/ghostscript.rb

main() {
    koopa_install_app_subshell \
        --installer='conda-env' \
        --name='ghostscript' \
        "$@"
}
