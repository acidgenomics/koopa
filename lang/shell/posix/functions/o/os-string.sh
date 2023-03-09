#!/bin/sh

_koopa_os_string() {
    # """
    # Operating system string.
    # @note Updated 2023-03-03.
    #
    # Alternatively, use 'hostnamectl'.
    # https://linuxize.com/post/how-to-check-linux-version/
    #
    # If we ever add Windows support, look for: cygwin, mingw32*, msys*.
    # """
    __kvar_id=''
    if _koopa_is_macos
    then
        __kvar_id='macos'
        __kvar_version="$(_koopa_major_version "$(_koopa_macos_os_version)")"
    elif _koopa_is_linux
    then
        __kvar_release_file='/etc/os-release'
        if [ -r "$__kvar_release_file" ]
        then
            __kvar_id="$( \
                awk -F= \
                    "\$1==\"ID\" { print \$2 ;}" \
                    "$__kvar_release_file" \
                | tr -d '"' \
            )"
            # Include the major release version.
            __kvar_version="$( \
                awk -F= \
                    "\$1==\"VERSION_ID\" { print \$2 ;}" \
                    "$__kvar_release_file" \
                | tr -d '"' \
            )"
            if [ -n "$__kvar_version" ]
            then
                __kvar_version="$(_koopa_major_version "$__kvar_version")"
            else
                # This is the case for Arch Linux.
                __kvar_version='rolling'
            fi
        else
            __kvar_id='linux'
            __kvar_version=''
        fi
    fi
    [ -n "$__kvar_id" ] ||  return 1
    __kvar_string="$__kvar_id"
    if [ -n "$__kvar_version" ]
    then
        __kvar_string="${__kvar_string}-${__kvar_version}"
    fi
    _koopa_print "$__kvar_string"
    unset -v \
        __kvar_id \
        __kvar_release_file \
        __kvar_string \
        __kvar_version
    return 0
}
