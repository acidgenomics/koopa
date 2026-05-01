#!/usr/bin/env bash

_koopa_linux_locate_ec2_metadata() {
    local app
    if _koopa_is_ubuntu_like
    then
        app='/usr/bin/ec2metadata'
    else
        # e.g. Amazon Linux 2.
        app='/usr/bin/ec2-metadata'
    fi
    _koopa_locate_app "$app" "$@"
}
