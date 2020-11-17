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

koopa::linux_install_lua() { # {{{1
    koopa::install_cellar \
        --name='lua' \
        --name-fancy='Lua' \
        "$@"
}

koopa::linux_install_luarocks() { # {{{1
    koopa::install_cellar \
        --name='luarocks' \
        "$@"
}

koopa::linux_install_neovim() { # {{{1
    koopa::install_cellar \
        --name='neovim' \
        "$@"
}

koopa::linux_install_openssh() { # {{{1
    koopa::install_cellar \
        --name='openssh' \
        --name-fancy='OpenSSH' \
        "$@"
}

koopa::linux_install_openssl() { # {{{1
    koopa::install_cellar \
        --name='openssl' \
        --name-fancy='OpenSSL' \
        --cellar-only \
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

koopa::linux_install_cellar_python() { # {{{1
    koopa::install_cellar \
        --name='python' \
        --name-fancy='Python' \
        "$@"
    koopa::install_py_koopa
}

koopa::linux_install_r() { # {{{1
    koopa::install_cellar \
        --name='r' \
        --name-fancy='R' \
        "$@"
    koopa::update_r_config
}

koopa::linux_install_ruby() { # {{{1
    koopa::install_cellar \
        --name='ruby' \
        --name-fancy='Ruby' \
        "$@"
}

koopa::linux_install_taglib() { # {{{1
    koopa::install_cellar \
        --name='taglib' \
        --name-fancy='TagLib' \
        "$@"
}

koopa::linux_install_udunits() { # {{{1
    koopa::install_cellar \
        --name='udunits' \
        "$@"
}

koopa::linux_install_vim() { # {{{1
    koopa::install_cellar \
        --name='vim' \
        --name-fancy='Vim' \
        "$@"
}
