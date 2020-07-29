#!/usr/bin/env bash

koopa::install_cellranger() { # {{{1
    # """
    # Install Cell Ranger.
    # @note Updated 2020-07-16.
    # """
    local file make_prefix name name_fancy prefix server tmp_dir url version
    version=
    while (("$#"))
    do
        case "$1" in
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --version)
                version="$2"
                shift 2
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    name='cellranger'
    name_fancy='Cell Ranger'
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    prefix="$(koopa::app_prefix)/${name}/${version}"
    koopa::exit_if_dir "$prefix"
    koopa::install_start "$name_fancy" "$prefix"
    tmp_dir="$(koopa::tmp_dir)/${name}"
    (
        koopa::cd "$tmp_dir"
        file="${name}-${version}.tar.gz"
        server='https://seq.cloud'
        url="${server}/install/cellranger/${file}"
        koopa::download "$url"
        koopa::extract "$file"
        koopa::sys_mv "${name}-${version}" "$prefix"
    )
    koopa::rm "$tmp_dir"
    # Link main 'cellranger' binary into make prefix (e.g. '/usr/local').
    make_prefix="$(koopa::make_prefix)"
    koopa::sys_ln "${prefix}/cellranger" "${make_prefix}/bin/cellranger"
    koopa::install_success "$name_fancy"
    return 0
}

