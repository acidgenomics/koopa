#!/usr/bin/env bash

koopa::linux_install_aws_cli() { # {{{1
    koopa::linux_install_app \
        --name='aws-cli' \
        --name-fancy='AWS CLI' \
        --version='latest' \
        --include-dirs='bin' \
        "$@"
}

koopa::linux_install_docker_credential_pass() { # {{{1
    koopa::linux_install_app \
        --name='docker-credential-pass' \
        "$@"
}

koopa::linux_install_gcc() { # {{{1
    koopa::linux_install_app \
        --name='gcc' \
        --name-fancy='GCC' "$@"
}

koopa::linux_install_gdal() { # {{{1
    koopa::linux_install_app \
        --name='gdal' \
        --name-fancy='GDAL' "$@"
}

koopa::linux_install_geos() { # {{{1
    koopa::linux_install_app \
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
    koopa::linux_install_app \
        --name='julia' \
        --name-fancy='Julia' \
        --script-name="$script_name" \
        "$@"
}

koopa::linux_install_lua() { # {{{1
    koopa::linux_install_app \
        --name='lua' \
        --name-fancy='Lua' \
        "$@"
}

koopa::linux_install_luarocks() { # {{{1
    koopa::linux_install_app \
        --name='luarocks' \
        "$@"
}

koopa::linux_install_neovim() { # {{{1
    koopa::linux_install_app \
        --name='neovim' \
        "$@"
}

koopa::linux_install_openssh() { # {{{1
    koopa::linux_install_app \
        --name='openssh' \
        --name-fancy='OpenSSH' \
        "$@"
}

koopa::linux_install_openssl() { # {{{1
    koopa::linux_install_app \
        --name='openssl' \
        --name-fancy='OpenSSL' \
        --no-link \
        "$@"
}

koopa::linux_install_password_store() { # {{{1
    koopa::linux_install_app \
        --name='password-store' \
        "$@"
}

koopa::linux_install_proj() { # {{{1
    koopa::linux_install_app \
        --name='proj' \
        --name-fancy='PROJ' \
        "$@"
}

koopa::linux_install_python() { # {{{1
    koopa::linux_install_app \
        --name='python' \
        --name-fancy='Python' \
        "$@"
}

koopa::linux_install_r() { # {{{1
    koopa::linux_install_app \
        --name='r' \
        --name-fancy='R' \
        "$@"
}

# NOTE Consider changing 'name' to 'r-devel' here?
koopa::linux_install_r_devel() { # {{{1
    koopa::linux_install_app \
        --name='r' \
        --name-fancy='R' \
        --version='devel' \
        --script-name='r-devel' \
        "$@"
}

koopa::linux_install_ruby() { # {{{1
    koopa::linux_install_app \
        --name='ruby' \
        --name-fancy='Ruby' \
        "$@"
}

koopa::linux_install_taglib() { # {{{1
    koopa::linux_install_app \
        --name='taglib' \
        --name-fancy='TagLib' \
        "$@"
}

koopa::linux_install_udunits() { # {{{1
    koopa::linux_install_app \
        --name='udunits' \
        "$@"
}

koopa::linux_install_vim() { # {{{1
    koopa::linux_install_app \
        --name='vim' \
        --name-fancy='Vim' \
        "$@"
}
