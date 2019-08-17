#!/bin/sh
# shellcheck disable=SC2039



# Updated 2019-08-17.
_koopa_macos_version() {
    _koopa_assert_is_darwin
    printf "%s %s (%s)\n" \
        "$(sw_vers -productName)" \
        "$(sw_vers -productVersion)" \
        "$(sw_vers -buildVersion)"
}



# Updated 2019-08-17.
_koopa_macos_version_short() {
    _koopa_assert_is_darwin
    printf "%s %s\n" \
        "macos" \
        "$(sw_vers -productVersion)"
}
