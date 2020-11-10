#!/usr/bin/env bash

koopa::find_cellar_symlinks() { # {{{1
    # """
    # Find cellar symlinks.
    # @note Updated 2020-08-13.
    # """
    local build_prefix cellar_prefix file links name version
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed find sort tail
    name="${1:?}"
    version="${2:-}"
    build_prefix="$(koopa::make_prefix)"
    # Automatically detect version, if left unset.
    cellar_prefix="$(koopa::cellar_prefix)/${name}"
    if [[ -n "$version" ]]
    then
        cellar_prefix="${cellar_prefix}/${version}"
    else
        cellar_prefix="$( \
            find "$cellar_prefix" -maxdepth 1 -type d \
            | sort \
            | tail -n 1 \
        )"
    fi
    # Pipe GNU find into array.
    readarray -t links <<< "$( \
        find -L "$build_prefix" \
            -type f \
            -path "${cellar_prefix}/*" \
            ! -path "${build_prefix}/koopa" \
            -print0 \
        | sort -z \
    )"
    # Replace the cellar prefix with our build prefix.
    for file in "${links[@]}"
    do
        koopa::print "${file//$cellar_prefix/$build_prefix}"
    done
    return 0
}

koopa::find_cellar_version() { # {{{1
    # """
    # Find cellar installation directory.
    # @note Updated 2020-06-30.
    # """
    local name prefix x
    koopa::assert_has_args "$#"
    name="${1:?}"
    prefix="$(koopa::cellar_prefix)"
    koopa::assert_is_dir "$prefix"
    prefix="${prefix}/${name}"
    koopa::assert_is_dir "$prefix"
    x="$( \
        find "$prefix" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
        | sort \
        | tail -n 1 \
    )"
    koopa::assert_is_dir "$x"
    x="$(basename "$x")"
    koopa::print "$x"
    return 0
}

koopa::install_autoconf() { # {{{1
    koopa::install_cellar \
        --name='autoconf' \
        "$@"
}

koopa::install_autojump() { # {{{1
    koopa::install_cellar \
        --name='autojump' \
        "$@"
}

koopa::install_automake() { # {{{1
    koopa::install_cellar \
        --name='automake' \
        "$@"
}

koopa::install_aws_cli() { # {{{1
    koopa::install_cellar \
        --name='aws-cli' \
        --name-fancy='AWS CLI' \
        --version='latest' \
        --include-dirs='bin' \
        "$@"
}

koopa::install_bash() { # {{{1
    koopa::install_cellar \
        --name='bash' \
        --name-fancy='Bash' \
        "$@"
}

koopa::install_binutils() { # {{{1
    koopa::install_cellar \
        --name='binutils' \
        "$@"
}

koopa::install_cellar() { # {{{1
    # """
    # Install cellarized application.
    # @note Updated 2020-08-07.
    # """
    local gnu_mirror include_dirs jobs link_args link_cellar make_prefix name \
        name_fancy pass_args prefix reinstall script_name script_path tmp_dir \
        version
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    include_dirs=
    link_cellar=1
    name_fancy=
    reinstall=0
    script_name=
    version=
    pass_args=()
    while (("$#"))
    do
        case "$1" in
            --cellar-only)
                link_cellar=0
                pass_args+=('--cellar-only')
                shift 1
                ;;
            --include-dirs=*)
                include_dirs="${1#*=}"
                shift 1
                ;;
            --name=*)
                name="${1#*=}"
                shift 1
                ;;
            --name-fancy=*)
                name_fancy="${1#*=}"
                shift 1
                ;;
            --reinstall)
                reinstall=1
                pass_args+=('--reinstall')
                shift 1
                ;;
            --script-name=*)
                script_name="${1#*=}"
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            "")
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    [[ -z "$name_fancy" ]] && name_fancy="$name"
    [[ -z "$script_name" ]] && script_name="$name"
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    prefix="$(koopa::cellar_prefix)/${name}/${version}"
    make_prefix="$(koopa::make_prefix)"
    if [[ "$reinstall" -eq 1 ]]
    then
        koopa::sys_rm "$prefix"
        koopa::remove_broken_symlinks "$make_prefix"
    fi
    [[ -d "$prefix" ]] && return 0
    koopa::install_start "$name_fancy" "$version" "$prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        # shellcheck disable=SC2034
        gnu_mirror="$(koopa::gnu_mirror)"
        # shellcheck disable=SC2034
        jobs="$(koopa::cpu_count)"
        koopa::cd "$tmp_dir"
        script_path="$(koopa::prefix)/os/linux/include/cellar/${script_name}.sh"
        # shellcheck source=/dev/null
        . "$script_path" "${pass_args[@]:-}"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::sys_set_permissions -r "$prefix"
    if [[ "$link_cellar" -eq 1 ]]
    then
        link_args=(
            "--name=${name}"
            "--version=${version}"
        )
        if [[ -n "$include_dirs" ]]
        then
            link_args+=("--include-dirs=${include_dirs}")
        fi
        koopa::link_cellar "${link_args[@]}"
    fi
    koopa::install_success "$name_fancy"
    return 0
}

koopa::install_cmake() { # {{{1
    koopa::install_cellar \
        --name='cmake' \
        --name-fancy='CMake' \
        "$@"
}

koopa::install_coreutils() { # {{{1
    koopa::install_cellar \
        --name='coreutils' \
        "$@"
}

koopa::install_curl() { # {{{1
    koopa::install_cellar \
        --name='curl' \
        --name-fancy='cURL' \
        "$@"
}

koopa::install_docker_credential_pass() { # {{{1
    koopa::install_cellar \
        --name='docker-credential-pass' \
        "$@"
}

koopa::install_emacs() { # {{{1
    koopa::install_cellar \
        --name='emacs' \
        --name-fancy='Emacs' \
        "$@"
}

koopa::install_findutils() { # {{{1
    koopa::install_cellar \
        --name='findutils' \
        "$@"
}

koopa::install_fish() { # {{{1
    koopa::install_cellar \
        --name='fish' \
        --name-fancy='Fish' \
        "$@"
}

koopa::install_gawk() { # {{{1
    koopa::install_cellar \
        --name='gawk' \
        --name-fancy='GNU awk' \
        "$@"
}

koopa::install_gcc() { # {{{1
    koopa::install_cellar \
        --name='gcc' \
        --name-fancy='GCC' \
        "$@"
}

koopa::install_gdal() { # {{{1
    koopa::install_cellar \
        --name='gdal' \
        --name-fancy='GDAL' \
        "$@"
}

koopa::install_geos() { # {{{1
    koopa::install_cellar \
        --name='geos' \
        --name-fancy='GEOS' \
        "$@"
}

koopa::install_git() { # {{{1
    koopa::install_cellar \
        --name='git' \
        --name-fancy='Git' \
        "$@"
}

koopa::install_gnupg() { # {{{1
    koopa::install_cellar \
        --name='gnupg' \
        --name-fancy='GnuPG suite' \
        "$@"
    koopa::is_installed gpg-agent && gpgconf --kill gpg-agent
    return 0
}

koopa::install_grep() { # {{{1
    koopa::install_cellar \
        --name='grep' \
        "$@"
}

koopa::install_gsl() { # {{{1
    koopa::install_cellar \
        --name='gsl' \
        --name-fancy='GSL' \
        --cellar-only \
        "$@"
}

koopa::install_hdf5() { # {{{1
    koopa::install_cellar \
        --name='hdf5' \
        --name-fancy='HDF5' \
        "$@"
}

koopa::install_htop() { # {{{1
    koopa::install_cellar \
        --name='htop' \
        "$@"
}

koopa::install_julia() { # {{{1
    local install_type pos
    install_type='binary'
    pos=()
    while (("$#"))
    do
        case "$1" in
            --binary)
                install_type='binary'
                shift 1
                ;;
            --source)
                install_type='source'
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
        --script-name="julia-${install_type}" \
        "$@"
}

koopa::install_libevent() { # {{{1
    koopa::install_cellar \
        --name='libevent' \
        "$@"
}

koopa::install_libtool() { # {{{1
    koopa::install_cellar \
        --name='libtool' \
        "$@"
}

koopa::install_lua() { # {{{1
    koopa::install_cellar \
        --name='lua' \
        --name-fancy='Lua' \
        "$@"
}

koopa::install_luarocks() { # {{{1
    koopa::install_cellar \
        --name='luarocks' \
        "$@"
}

koopa::install_make() { # {{{1
    koopa::install_cellar \
        --name='make' \
        "$@"
}

koopa::install_ncurses() { # {{{1
    koopa::install_cellar \
        --name='ncurses' \
        "$@"
}

koopa::install_neofetch() { # {{{1
    koopa::install_cellar \
        --name='neofetch' \
        "$@"
}

koopa::install_neovim() { # {{{1
    koopa::install_cellar \
        --name='neovim' \
        "$@"
}

koopa::install_openssh() { # {{{1
    koopa::install_cellar \
        --name='openssh' \
        --name-fancy='OpenSSH' \
        "$@"
}

koopa::install_openssl() { # {{{1
    koopa::install_cellar \
        --name='openssl' \
        --name-fancy='OpenSSL' \
        --cellar-only \
        "$@"
}

koopa::install_parallel() { # {{{1
    koopa::install_cellar \
        --name='parallel' \
        "$@"
}

koopa::install_password_store() { # {{{1
    # """
    # https://www.passwordstore.org/
    # https://git.zx2c4.com/password-store/
    # """
    koopa::install_cellar \
        --name='password-store' \
        "$@"
}

koopa::install_patch() { # {{{1
    koopa::install_cellar \
        --name='patch' \
        "$@"
}

koopa::install_perl() { # {{{1
    koopa::install_cellar \
        --name='perl' \
        --name-fancy='Perl' \
        "$@"
}

koopa::install_pkg_config() { # {{{1
    koopa::install_cellar \
        --name='pkg-config' \
        "$@"
}

koopa::install_proj() { # {{{1
    koopa::install_cellar \
        --name='proj' \
        --name-fancy='PROJ' \
        "$@"
}

koopa::install_pyenv() { # {{{1
    koopa::install_cellar \
        --name='pyenv' \
        "$@"
}

koopa::install_python() { # {{{1
    koopa::install_cellar \
        --name='python' \
        --name-fancy='Python' \
        "$@"
}

koopa::install_r() { # {{{1
    koopa::install_cellar \
        --name='r' \
        --name-fancy='R' \
        "$@"
}

koopa::install_rbenv() { # {{{1
    koopa::install_cellar \
        --name='rbenv' \
        "$@"
}

koopa::install_rmate() { # {{{1
    koopa::install_cellar \
        --name='rmate' \
        "$@"
}

koopa::install_rsync() { # {{{1
    koopa::install_cellar \
        --name='rsync' \
        "$@"
}

koopa::install_ruby() { # {{{1
    koopa::install_cellar \
        --name='ruby' \
        --name-fancy='Ruby' \
        "$@"
}

koopa::install_sed() { # {{{1
    koopa::install_cellar \
        --name='sed' \
        "$@"
}

koopa::install_shellcheck() { # {{{1
    koopa::install_cellar \
        --name='shellcheck' \
        --name-fancy='ShellCheck' \
        "$@"
}

koopa::install_shunit2() { # {{{1
    koopa::install_cellar \
        --name='shunit2' \
        --name-fancy='shUnit2' \
        "$@"
}

koopa::install_singularity() { # {{{1
    koopa::install_cellar \
        --name='singularity' \
        "$@"
}

koopa::install_sqlite() { # {{{1
    koopa::install_cellar \
        --name='sqlite' \
        --name-fancy='SQLite' \
        "$@"
    koopa::note 'Reinstall PROJ and GDAL, if built from source.'
    return 0
}

koopa::install_subversion() { # {{{1
    koopa::install_cellar \
        --name='subversion' \
        "$@"
}

koopa::install_taglib() { # {{{1
    koopa::install_cellar \
        --name='taglib' \
        --name-fancy='TagLib' \
        "$@"
}

koopa::install_texinfo() { # {{{1
    koopa::install_cellar \
        --name='texinfo' \
        "$@"
}

koopa::install_the_silver_searcher() { # {{{1
    koopa::install_cellar \
        --name='the-silver-searcher' \
        "$@"
}

koopa::install_tmux() { # {{{1
    koopa::install_cellar \
        --name='tmux' \
        "$@"
}

koopa::install_udunits() { # {{{1
    koopa::install_cellar \
        --name='udunits' \
        "$@"
}

koopa::install_vim() { # {{{1
    koopa::install_cellar \
        --name='vim' \
        --name-fancy='Vim' \
        "$@"
}

koopa::install_wget() { # {{{1
    koopa::install_cellar \
        --name='wget' \
        "$@"
}

koopa::install_zsh() { # {{{1
    koopa::install_cellar \
        --name='zsh' \
        --name-fancy='Zsh' \
        "$@"
    koopa::fix_zsh_permissions
    return 0
}

koopa::link_cellar() { # {{{1
    # """
    # Symlink cellar into build directory.
    # @note Updated 2020-11-10.
    #
    # If you run into permissions issues during link, check the build prefix
    # permissions. Ensure group is not 'root', and that group has write access.
    #
    # This can be reset easily with 'koopa::sys_set_permissions'.
    #
    # Note that Debian symlinks 'man' to 'share/man', which is non-standard.
    # This is currently corrected in 'install-debian-base', but top-level
    # symlink checks may need to be added here in a future update.
    #
    # @section cp flags:
    # * -f, --force
    # * -R, -r, --recursive
    # * -s, --symbolic-link
    #
    # @examples
    # koopa::link_cellar emacs 26.3
    # """
    local cellar_prefix cellar_subdirs include_dirs make_prefix name pos version
    include_dirs=
    version=
    pos=()
    while (("$#"))
    do
        case "$1" in
            --include-dirs=*)
                include_dirs="${1#*=}"
                shift 1
                ;;
            --name=*)
                name="${1#*=}"
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    [[ -n "${1:-}" ]] && name="$1"
    koopa::assert_has_no_envs
    make_prefix="$(koopa::make_prefix)"
    koopa::assert_is_dir "$make_prefix"
    cellar_prefix="$(koopa::cellar_prefix)"
    koopa::assert_is_dir "$cellar_prefix"
    cellar_prefix="${cellar_prefix}/${name}"
    koopa::assert_is_dir "$cellar_prefix"
    [[ -z "$version" ]] && version="$(koopa::find_cellar_version "$name")"
    cellar_prefix="${cellar_prefix}/${version}"
    koopa::assert_is_dir "$cellar_prefix"
    koopa::h2 "Linking '${cellar_prefix}' in '${make_prefix}'."
    koopa::sys_set_permissions -r "$cellar_prefix"
    koopa::remove_broken_symlinks "$cellar_prefix"
    koopa::remove_broken_symlinks "$make_prefix"
    cellar_subdirs=()
    if [[ -n "$include_dirs" ]]
    then
        IFS=',' read -r -a cellar_subdirs <<< "$include_dirs"
        cellar_subdirs=("${cellar_subdirs[@]/^/${cellar_prefix}}")
        for i in "${!cellar_subdirs[@]}"
        do
            cellar_subdirs[$i]="${cellar_prefix}/${cellar_subdirs[$i]}"
        done
    else
        readarray -t cellar_subdirs <<< "$( \
            find "$cellar_prefix" \
                -mindepth 1 \
                -maxdepth 1 \
                -type d \
                -print \
            | sort \
        )"
    fi
    echo "FIXME 1"
    echo "${cellar_subdirs[@]}"
    # Copy as symbolic links.
    koopa::cp \
        -s \
        -t "${make_prefix}" \
        "${cellar_subdirs[@]}"
    echo "FIXME 2"
    koopa::is_shared_install && koopa::update_ldconfig
    koopa::success "Successfully linked '${name}'."
    return 0
}

koopa::list_cellar_versions() { # {{{1
    local prefix
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::cellar_prefix)"
    (
        koopa::cd "$prefix"
        ls -1 -- *
    )
    return 0
}

koopa::remove_broken_cellar_symlinks() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::remove_broken_symlinks "$(koopa::make_prefix)"
    return 0
}
