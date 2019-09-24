#!/bin/sh
# shellcheck disable=SC2039



# Extract the version of a macOS application.
# Updated 2019-09-24.
_koopa_macos_app_version() {
    _koopa_assert_is_darwin
    plutil -p "/Applications/${1}.app/Contents/Info.plist" | \
        grep CFBundleShortVersionString |
        awk -F ' => ' '{print $2}' |
        tr -d '"'
        # > cut -d ' ' -f 1
}



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
    version="$(sw_vers -productVersion | cut -d '.' -f 1-2)"
    printf "%s %s\n" "macos" "$version"
}



# Get the major program version.
# Updated 2019-09-23.
_koopa_major_version() {
    echo "$1" | cut -d '.' -f 1-2
}



# Get the minor program version.
# Updated 2019-09-23.
_koopa_minor_version() {
    echo "$1" | cut -d "." -f 2-
}
