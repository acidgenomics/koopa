#!/usr/bin/env bash

koopa::install_go() {
    # """
    # Install Go.
    # @note Updated 2020-07-16.
    # """
    local app_prefix cellar_prefix goroot link_cellar name name_fancy \
        reinstall tmp_dir version
    koopa::assert_has_no_envs
    name='go'
    name_fancy='Go'
    link_cellar=1
    reinstall=0
    version=
    while (("$#"))
    do
        case "$1" in
            --cellar-only)
                link_cellar=0
                shift 1
                ;;
            --reinstall)
                reinstall=1
                shift 1
                ;;
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
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    app_prefix="$(koopa::app_prefix)/${name}/${version}"
    cellar_prefix="$(koopa::cellar_prefix)/${name}/${version}"
    [[ "$reinstall" -eq 1 ]] && koopa::sys_rm "$app_prefix" "$cellar_prefix"
    koopa::exit_if_dir "$app_prefix" "$cellar_prefix"
    koopa::install_start "$name_fancy" "$version" "$cellar_prefix"
    koopa::mkdir "$app_prefix"
    koopa::mkdir "$cellar_prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file="go${version}.linux-amd64.tar.gz"
        url="https://dl.google.com/go/${file}"
        koopa::download "$url"
        koopa::extract "$file"
        koopa::cp -t "$app_prefix" 'go/'*
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::sys_set_permissions -r "$app_prefix"
    koopa::h2 "Linking from \"${app_prefix}\" into \"${cellar_prefix}\"."
    koopa::cp -t "$cellar_prefix" "${app_prefix}/bin"
    if [[ "$link_cellar" -eq 1 ]]
    then
        koopa::link_cellar "$name" "$version"
        # Need to create directory expected by GOROOT environment variable.
        # If this doesn't exist, Go will currently error.
        goroot='/usr/local/go'
        koopa::h2 "Linking GOROOT directory at \"${goroot}\"."
        koopa::ln "$app_prefix" "$goroot"
        # > go env GOROOT
    fi
    koopa::install_success "$name_fancy"
    return 0
}

