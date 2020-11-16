#!/usr/bin/env bash

koopa::linux_install_aws_cli() { # {{{1
    koopa::install_cellar \
        --name='aws-cli' \
        --name-fancy='AWS CLI' \
        --version='latest' \
        --include-dirs='bin' \
        "$@"
}

koopa::linux_install_docker_credential_pass() { # {{{1
    koopa::install_cellar \
        --name='docker-credential-pass' \
        "$@"
}

koopa::linux_install_gcc() { # {{{1
    koopa::install_cellar \
        --name='gcc' \
        --name-fancy='GCC' \
        "$@"
}

koopa::linux_install_gdal() { # {{{1
    koopa::install_cellar \
        --name='gdal' \
        --name-fancy='GDAL' \
        "$@"
}

koopa::linux_install_geos() { # {{{1
    koopa::install_cellar \
        --name='geos' \
        --name-fancy='GEOS' \
        "$@"
}

koopa::linux_install_julia() { # {{{1
    local pos script_name
    script_name='julia'
    pos=()
    while (("$#"))
    do
        case "$1" in
            --binary)
                script_name='julia-binary'
                shift 1
                ;;
            --source)
                script_name='julia'
                shift 1
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::install_cellar \
        --name='julia' \
        --name-fancy='Julia' \
        --script-name="$script_name" \
        "$@"
}

koopa::linux_install_password_store() { # {{{1
    # """
    # https://www.passwordstore.org/
    # https://git.zx2c4.com/password-store/
    # """
    koopa::install_cellar \
        --name='password-store' \
        "$@"
}

koopa::linux_install_proj() { # {{{1
    koopa::install_cellar \
        --name='proj' \
        --name-fancy='PROJ' \
        "$@"
}
