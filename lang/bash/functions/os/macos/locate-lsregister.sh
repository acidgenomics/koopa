#!/usr/bin/env bash

_koopa_macos_locate_lsregister() {
    _koopa_locate_app \
        "/System/Library/Frameworks/CoreServices.framework\
/Frameworks/LaunchServices.framework/Support/lsregister" \
        "$@"
}
