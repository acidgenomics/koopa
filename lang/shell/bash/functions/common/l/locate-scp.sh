#!/usr/bin/env bash

koopa_locate_scp() {
    local args
    if koopa_is_macos
    then
        # This works better with macOS keychain.
        args=('/usr/bin/scp')
    else
        args=(
            '--allow-in-path'
            '--app-name=scp'
            '--opt-name=openssh'
        )
    fi
    koopa_locate_app "${args[@]}"
}
