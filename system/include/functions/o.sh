#!/bin/sh
# shellcheck disable=SC2039



# Updated 2019-06-25.
_koopa_os_type() {
    local name
    if _koopa_is_darwin
    then
        name="$(uname -s | tr '[:upper:]' '[:lower:]')"
    elif _koopa_is_linux
    then
        name="$( \
            awk -F= '$1=="ID" { print $2 ;}' /etc/os-release | \
            tr -d '"' \
        )"
	# Include the major release version for RHEL.
	if [ "$name" = "rhel" ]
	then
        major_version="$( \
            awk -F= '$1=="VERSION_ID" { print $2 ;}' /etc/os-release | \
            tr -d '"' | \
            cut -d '.' -f 1
        )"
        name="${name}${major_version}"
	fi
    else
        name=
    fi
    echo "$name"
}



# Updated 2019-06-22.
_koopa_os_version() {
    uname -r
}
