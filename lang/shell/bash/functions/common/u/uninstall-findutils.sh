#!/usr/bin/env bash

koopa_uninstall_findutils() {
    local uninstall_args
    uninstall_args=(
        '--name=findutils'
        '--unlink-in-bin=find'
        '--unlink-in-bin=locate'
        '--unlink-in-bin=updatedb'
        '--unlink-in-bin=xargs'
    )
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}
