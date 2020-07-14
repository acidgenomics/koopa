#!/usr/bin/env bash

koopa::macos_clean_launch_services() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::h1 'Cleaning LaunchServices "Open With" menu.'
    "/System/Library/Frameworks/CoreServices.framework/Frameworks/\
LaunchServices.framework/Support/lsregister" \
        -kill \
        -r \
        -domain 'local' \
        -domain 'system' \
        -domain 'user'
    killall Finder
    koopa::success 'Clean up was successful.'
    return 0
}
