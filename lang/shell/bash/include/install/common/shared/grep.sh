#!/usr/bin/env bash

# FIXME This isn't detecting pcre correctly...
# checking for PCRE... no
# checking for pcre2_compile... no
# configure: WARNING: GNU grep will be built without PCRE support.

main() {
    koopa_activate_opt_prefix 'pcre2'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='grep' \
        -D '--disable-dependency-tracking' \
        -D '--disable-nls' \
        -D '--program-prefix=g' \
        "$@"
}
