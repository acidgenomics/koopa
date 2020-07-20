#!/usr/bin/env bash

koopa::install_fzf() {
    # """
    # Install fzf.
    # @note Updated 2020-07-20.
    #
    # This script will download files into '~/go'.
    #
    # @seealso
    # - https://github.com/junegunn/fzf/blob/master/BUILD.md
    # """
    local goroot jobs name prefix prefix_parent reinstall tmp_dir version
    koopa::assert_has_no_envs
    name='fzf'
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
            --version)
                version="$2"
                shift 2
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::fzf_prefix)/${version}"
    [[ "$reinstall" -eq 1 ]] && koopa::rm "$prefix"
    koopa::exit_if_dir "$prefix"
    koopa::install_start "$name" "$version" "$prefix"
    koopa::activate_go
    koopa::assert_is_installed go
    goroot="$(go env GOROOT)"
    koopa::dl 'GOROOT' "$goroot"
    prefix_parent="$(dirname "$prefix")"
    jobs="$(koopa::cpu_count)"
    koopa::mkdir "$prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file="${version}.tar.gz"
        koopa::download "https://github.com/junegunn/fzf/archive/${file}"
        koopa::extract "$file"
        koopa::cd "${name}-${version}"
        make --jobs="$jobs"
        # > make test
        # This will copy fzf binary from 'target/' to 'bin/' inside tmp dir.
        # Note that this step does not copy to '/usr/bin/'.
        make install
        # > ./install --help
        ./install --bin --no-update-rc
        # Following approach used in Homebrew recipe here.
        koopa::rm .[[:alnum:]]* 'src' 'target'
        koopa::cp . "$prefix"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    (
        koopa::cd "$prefix_parent"
        koopa::sys_ln "$version" "latest"
    )
    koopa::sys_set_permissions -r "$prefix_parent"
    koopa::install_success "$name"
    koopa::note 'Reload the shell to complete activation.'
    return 0
}

