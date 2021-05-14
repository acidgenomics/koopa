#!/usr/bin/env bash

koopa::macos_clean_launch_services() { # {{{1
    # """
    # Clean launch services.
    # @note Updated 2020-11-18.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::h1 "Cleaning LaunchServices 'Open With' menu."
    "/System/Library/Frameworks/CoreServices.framework/Frameworks/\
LaunchServices.framework/Support/lsregister" \
        -kill \
        -r \
        -domain 'local' \
        -domain 'system' \
        -domain 'user'
    killall Finder
    koopa::alert_success 'Clean up was successful.'
    return 0
}

koopa::macos_flush_dns() { # {{{1
    # """
    # Flush DNS cache.
    # @note Updated 2020-07-18.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::h1 'Flushing DNS.'
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    koopa::alert_success 'DNS flush was successful.'
    return 0
}
