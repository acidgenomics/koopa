#!/bin/sh

_koopa_os_string() {
    # """
    # Operating system string.
    # @note Updated 2023-01-10.
    #
    # Alternatively, use 'hostnamectl'.
    # https://linuxize.com/post/how-to-check-linux-version/
    #
    # If we ever add Windows support, look for: cygwin, mingw32*, msys*.
    # """
    local id release_file string version
    if _koopa_is_macos
    then
        id='macos'
        version="$(koopa_major_version "$(koopa_macos_os_version)")"
    elif _koopa_is_linux
    then
        release_file='/etc/os-release'
        if [ -r "$release_file" ]
        then
            id="$( \
                awk -F= \
                    "\$1==\"ID\" { print \$2 ;}" \
                    "$release_file" \
                | tr -d '"' \
            )"
            # Include the major release version.
            version="$( \
                awk -F= \
                    "\$1==\"VERSION_ID\" { print \$2 ;}" \
                    "$release_file" \
                | tr -d '"' \
            )"
            if [ -n "$version" ]
            then
                version="$(koopa_major_version "$version")"
            else
                # This is the case for Arch Linux.
                version='rolling'
            fi
        else
            id='linux'
            version=''
        fi
    fi
    [ -n "$id" ] ||  return 1
    string="$id"
    [ -n "$version" ] && string="${string}-${version}"
    _koopa_print "$string"
    return 0
}
