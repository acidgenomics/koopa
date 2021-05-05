#!/usr/bin/env bash

# FIXME Need to wrap in install_app call.

koopa::install_go() { # {{{1
    # """
    # Install Go.
    # @note Updated 2021-03-30.
    # """
    local arch name name_fancy os_id prefix prefix_parent reinstall \
        tmp_dir version
    name='go'
    name_fancy='Go'
    reinstall=0
    version=
    while (("$#"))
    do
        case "$1" in
            --reinstall)
                reinstall=1
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    prefix="$(koopa::go_prefix)/${version}"
    [[ "$reinstall" -eq 1 ]] && koopa::rm "$prefix"
    [[ -d "$prefix" ]] && return 0
    koopa::install_start "$name_fancy" "$version" "$prefix"
    prefix_parent="$(dirname "$prefix")"
    koopa::mkdir "$prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        if koopa::is_macos
        then
            os_id='darwin'
        else
            os_id='linux'
        fi
        arch="$(koopa::arch)"
        file="go${version}.${os_id}-${arch}.tar.gz"
        url="https://dl.google.com/go/${file}"
        koopa::download "$url"
        koopa::extract "$file"
        koopa::cp -t "$prefix" 'go/'*
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    (
        koopa::cd "$prefix_parent"
        koopa::sys_ln "$version" 'latest'
    )
    koopa::sys_set_permissions -r "$prefix_parent"
    koopa::install_success "$name_fancy"
    koopa::alert_note 'Reload the shell to complete activation.'
    return 0
}

