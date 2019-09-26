#!/bin/sh
# shellcheck disable=SC2039



# Detect activation of virtual environments.
# Updated 2019-06-25.
_koopa_has_no_environments() {
    [ -x "$(command -v conda)" ] && [ -n "${CONDA_PREFIX:-}" ] && return 1
    [ -x "$(command -v deactivate)" ] && return 1
    return 0
}



# Administrator (sudo) permission.
# Currently performing a simple check by verifying wheel group.
# - Darwin (macOS): admin
# - Debian: sudo
# - Fedora: wheel
# Updated 2019-06-19.
_koopa_has_sudo() {
    groups | grep -Eq "\b(admin|sudo|wheel)\b"
}



# Source script header.
# Updated 2019-06-27.
_koopa_header() {
    local path

    if [ -z "${1:-}" ]
    then
        >&2 cat << EOF
error: TYPE argument missing.
usage: _koopa_header TYPE

shell:
    - bash
    - zsh

os type:
    - darwin
    - linux
        - debian
            - ubuntu
        - fedora
            - [rhel]
                - amzn

host type:
    - azure
    - harvard-o2
    - harvard-odyssey
EOF

        return 1
    fi
    
    case "$1" in
        # shell
        bash)
            path="${KOOPA_HOME}/shell/bash/include/header.sh"
            ;;
        zsh)
            path="${KOOPA_HOME}/shell/zsh/include/header.sh"
            ;;

        # os
        darwin)
            path="${KOOPA_HOME}/os/darwin/include/header.sh"
            ;;
        linux)
            path="${KOOPA_HOME}/os/linux/include/header.sh"
            ;;
            debian)
                path="${KOOPA_HOME}/os/debian/include/header.sh"
                ;;
                ubuntu)
                    path="${KOOPA_HOME}/os/ubuntu/include/header.sh"
                    ;;
            fedora)
                path="${KOOPA_HOME}/os/fedora/include/header.sh"
                ;;
                amzn)
                    path="${KOOPA_HOME}/os/amzn/include/header.sh"
                    ;;

        # host
        azure)
            path="${KOOPA_HOME}/host/azure/include/header.sh"
            ;;
        harvard-o2)
            path="${KOOPA_HOME}/host/harvard-o2/include/header.sh"
            ;;
        harvard-odyssey)
            path="${KOOPA_HOME}/host/harvard-odyssey/include/header.sh"
            ;;

        *)
            >&2 printf "Error: '%s' is not supported.\n" "$1"
            return 1
            ;;
    esac

    echo "$path"
}



# Show usage via help flag.
# Updated 2019-09-26.
_koopa_help() {
    case "${1:-}" in
        --help|-h)
            usage
            exit 0
            ;;
    esac
}



# Updated 2019-08-18.
_koopa_home() {
    echo "$KOOPA_HOME"
}



# Simple host type name string to load up host-specific scripts.
# Currently intended to support AWS, Azure, and Harvard clusters.
#
# Returns useful host type matching either:
# - VMs: "aws", "azure".
# - HPCs: "harvard-o2", "harvard-odyssey".
#
# Returns empty for local machines and/or unsupported types.
# Updated 2019-08-18.
_koopa_host_type() {
    local name
    case "$(hostname -f)" in
        # VMs
        *.ec2.internal)
            name="aws"
            ;;
        azlabapp*)
            name="azure"
            ;;
        # HPCs
        *.o2.rc.hms.harvard.edu)
            name="harvard-o2"
            ;;
        *.rc.fas.harvard.edu)
            name="harvard-odyssey"
            ;;
        *)
            name=
            ;;
    esac
    echo "$name"
}
