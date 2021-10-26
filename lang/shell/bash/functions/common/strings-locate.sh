#!/usr/bin/env bash

koopa:::locate_app() { # {{{1
    # """
    # Locate file system path to an application.
    # @note Updated 2021-10-25.
    #
    # App locator prioritization:
    # 1. Allow for direct input of a program path.
    # 2. Check in make prefix (e.g. '/usr/local').
    # 3. Check in koopa opt.
    # 4. Check in Homebrew opt.
    # 5. Check in system library.
    #
    # Resolving the full executable path can cause BusyBox coreutils to error.
    # """
    local app dict pos
    declare -A dict=(
        [app_name]=''
        [brew_app]=''
        [brew_opt_name]=''
        [brew_prefix]="$(koopa::homebrew_prefix)"
        [gnubin]=0
        [koopa_app]=''
        [koopa_opt_name]=''
        [koopa_opt_prefix]="$(koopa::opt_prefix)"
        [macos_app]=''
        [make_prefix]="$(koopa::make_prefix)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--brew-opt='*)
                dict[brew_opt_name]="${1#*=}"
                shift 1
                ;;
            '--brew-opt')
                dict[brew_opt_name]="${2:?}"
                shift 2
                ;;
            '--koopa-opt='*)
                dict[koopa_opt_name]="${1#*=}"
                shift 1
                ;;
            '--koopa-opt')
                dict[koopa_opt_name]="${2:?}"
                shift 2
                ;;
            '--macos-app='*)
                dict[macos_app]="${1#*=}"
                shift 1
                ;;
            '--macos-app')
                dict[macos_app]="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict[app_name]="${1#*=}"
                shift 1
                ;;
            '--name')
                dict[app_name]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--gnubin')
                dict[gnubin]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args_le "$#" 1
    # Allow simple input using a single positional argument for name.
    if [[ -z "${dict[app_name]}" ]]
    then
        koopa::assert_has_args_eq "$#" 1
        dict[app_name]="${1:?}"
    fi
    if [[ -z "${dict[brew_opt_name]}" ]]
    then
        dict[brew_opt_name]="${dict[app_name]}"
    fi
    if [[ -z "${dict[koopa_opt_name]}" ]]
    then
        dict[koopa_opt_name]="${dict[app_name]}"
    fi
    # Prepare paths where to look for app.
    dict[make_app]="${dict[make_prefix]}/bin/${dict[app_name]}"
    dict[koopa_app]="${dict[koopa_opt_prefix]}/${dict[koopa_opt_name]}/\
bin/${dict[app_name]}"
    if [[ "${dict[gnubin]}" -eq 1 ]]
    then
        dict[brew_app]="${dict[brew_prefix]}/opt/${dict[brew_opt_name]}/\
libexec/gnubin/${dict[app_name]}"
    else
        dict[brew_app]="${dict[brew_prefix]}/opt/${dict[brew_opt_name]}/\
bin/${dict[app_name]}"
    fi
    # Ready to locate the application by priority.
    if [[ -x "${dict[macos_app]}" ]] && koopa::is_macos
    then
        app="${dict[macos_app]}"
    elif [[ -x "${dict[app_name]}" ]]
    then
        app="${dict[app_name]}"
    elif [[ "${dict[brew_prefix]}" != "${dict[make_prefix]}" ]] && \
        [[ -x "${dict[make_app]}" ]]
    then
        app="${dict[make_app]}"
    elif [[ -x "${dict[koopa_app]}" ]]
    then
        app="${dict[koopa_app]}"
    elif [[ "${dict[brew_prefix]}" == "${dict[make_prefix]}" ]] && \
        [[ -x "${dict[make_app]}" ]]
    then
        app="${dict[make_app]}"
    elif [[ -x "${dict[brew_app]}" ]]
    then
        app="${dict[brew_app]}"
    else
        # Using 'realpath' here causes issues with Alpine BusyBox coreutils.
        app="$(koopa::which "${dict[app_name]}")"
    fi
    if [[ -z "$app" ]]
    then
        koopa::warn "Failed to locate '${dict[app_name]}'."
        return 1
    fi
    if [[ ! -x "$app" ]]
    then
        koopa::warn "Not executable: '${app}'."
        return 1
    fi
    koopa::print "$app"
    return 0
}

koopa::locate_7z() { # {{{1
    # """
    # Locate 7z.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='p7zip' \
        --name='7z'
}

koopa::locate_anaconda() { # {{{1
    # """
    # Locate conda inside Anaconda install.
    # @note Updated 2021-10-26.
    #
    # @seealso
    # - https://github.com/mamba-org/mamba
    # - https://github.com/conda-forge/miniforge
    # """
    local prefix x
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::anaconda_prefix)"
    x="${prefix}/bin/conda"
    [[ -x "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::locate_ascp() { # {{{1
    # """
    # Locate Aspera Connect ascp.
    # @note Updated 2021-10-13.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --koopa-opt='aspera-connect' \
        --macos-app="${HOME}/Applications/Aspera Connect.app/\
Contents/Resources/ascp" \
        --name='ascp'
}

koopa::locate_awk() { # {{{1
    # """
    # Locate GNU awk.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='gawk' \
        --gnubin \
        --name='awk'
}

koopa::locate_aws() { # {{{1
    # """
    # Locate AWS CLI.
    # @note Updated 2021-09-20.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'aws'
}

koopa::locate_basename() { # {{{1
    # """
    # Locate GNU basename.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='basename'
}

koopa::locate_bc() { # {{{1
    # """
    # Locate GNU bc.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'bc'
}

koopa::locate_bpytop() { # {{{1
    # """
    # Locate bpytop.
    # @note Updated 2021-10-25.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --koopa-opt='python-packages' \
        --name='bpytop'
}

koopa::locate_brew() { # {{{1
    # """
    # Locate Homebrew brew.
    # @note Updated 2021-09-20.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'brew'
}

koopa::locate_bundle() { # {{{1
    # """
    # Locate Ruby bundler (bundle).
    # @note Updated 2021-09-21.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='ruby' \
        --koopa-opt='ruby-packages' \
        --name='bundle'
}

koopa::locate_bunzip2() { # {{{1
    # """
    # Locate bunzip2.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='bzip2' \
        --name='bunzip2'
}

koopa::locate_cargo() { # {{{1
    # """
    # Locate cargo.
    # @note Updated 2021-09-20.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='rust' \
        --koopa-opt='rust-packages' \
        --name='cargo'
}

koopa::locate_chgrp() { # {{{1
    # """
    # Locate GNU chgrp.
    # @note Updated 2021-10-22.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app '/usr/bin/chgrp'
}

koopa::locate_chmod() { # {{{1
    # """
    # Locate GNU chmod.
    # @note Updated 2021-10-22.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app '/bin/chmod'
}

koopa::locate_chown() { # {{{1
    # """
    # Locate GNU chown.
    # @note Updated 2021-10-22.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app '/usr/sbin/chown'
}

koopa::locate_cmake() { # {{{1
    # """
    # Locate cmake.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'cmake'
}

koopa::locate_conda() { # {{{1
    # """
    # Locate conda inside Miniconda install.
    # @note Updated 2021-10-26.
    #
    # @seealso
    # - https://github.com/mamba-org/mamba
    # - https://github.com/conda-forge/miniforge
    # """
    local prefix x
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::conda_prefix)"
    x="${prefix}/bin/conda"
    [[ -x "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::locate_cp() { # {{{1
    # """
    # Locate GNU cp.
    # @note Updated 2021-10-22.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app '/bin/cp'
}

koopa::locate_curl() { # {{{1
    # """
    # Locate curl.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'curl'
}

koopa::locate_cut() { # {{{1
    # """
    # Locate GNU cut.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='cut'
}

koopa::locate_date() { # {{{1
    # """
    # Locate GNU date.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='date'
}

koopa::locate_df() { # {{{1
    # """
    # Locate GNU df.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='df'
}

koopa::locate_dig() { # {{{1
    # """
    # Locate BIND dig.
    # @note Updated 2021-10-25.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='bind' \
        --name='dig'
}

koopa::locate_dirname() { # {{{1
    # """
    # Locate GNU dirname.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='dirname'
}

koopa::locate_docker() { # {{{1
    # """
    # Locate Docker.
    # @note Updated 2021-10-25.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'docker'
}

koopa::locate_doom() { # {{{1
    # """
    # Locate Doom Emacs.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app "$(koopa::doom_emacs_prefix)/bin/doom"
}

koopa::locate_du() { # {{{1
    # """
    # Locate GNU du.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='du'
}

koopa::locate_emacs() { # {{{1
    # """
    # Locate Emacs.
    # @note Updated 2021-09-23.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'emacs'
}

koopa::locate_fd() { # {{{1
    # """
    # Locate Rust fd (find).
    # @note Updated 2021-10-22.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='fd' \
        --koopa-opt='rust-packages' \
        --name='fd'
}

koopa::locate_find() { # {{{1
    # """
    # Locate GNU find.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='findutils' \
        --gnubin \
        --name='find'
}

koopa::locate_fish() { # {{{1
    # """
    # Locate fish shell.
    # @note Updated 2021-09-17.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'fish'
}

koopa::locate_gcc() { # {{{1
    # """
    # Locate GNU gcc.
    # @note Updated 2021-09-15.
    # """
    local name version
    koopa::assert_has_no_args "$#"
    name='gcc'
    version="$(koopa::variable "$name")"
    version="$(koopa::major_version "$version")"
    koopa:::locate_app \
        --brew-opt="${name}@${version}" \
        --name="${name}-${version}"
}

koopa::locate_gcloud() { # {{{1
    # """
    # Locate gcloud.
    # @note Updated 2021-09-20.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'gcloud'
}

koopa::locate_gem() { # {{{1
    # """
    # Locate Ruby gem package manager.
    # @note Updated 2021-09-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='ruby' \
        --name='gem'
}

koopa::locate_git() { # {{{1
    # """
    # Locate git.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'git'
}

koopa::locate_go() { # {{{1
    # """
    # Locate go.
    # @note Updated 2021-09-17.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'go'
}

koopa::locate_gpg() { # {{{1
    # """
    # Locate gpg.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --macos-app='/usr/local/MacGPG2/bin/gpg' \
        --name='gpg'
}

koopa::locate_grep() { # {{{1
    # """
    # Locate GNU grep.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --gnubin \
        --name='grep'
}

koopa::locate_gunzip() { # {{{1
    # """
    # Locate GNU gunzip.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='gzip' \
        --name='gunzip'
}

koopa::locate_gzip() { # {{{1
    # """
    # Locate GNU gzip.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'gzip'
}

koopa::locate_head() { # {{{1
    # """
    # Locate GNU head.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='head'
}

koopa::locate_id() { # {{{1
    # """
    # Locate GNU id.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='id'
}

koopa::locate_julia() { # {{{1
    # """
    # Locate Julia.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --macos-app="$(koopa::macos_julia_prefix)/bin/julia" \
        --name='julia'
}

koopa::locate_llvm_config() { # {{{1
    # """
    # Locate 'llvm-config' executable.
    # @note Updated 2021-09-15.
    #
    # This is versioned on many Linux systems.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    app='llvm-config'
    if [[ -n "${LLVM_CONFIG:-}" ]]
    then
        app="${LLVM_CONFIG:?}"
    elif koopa::is_linux && ! koopa::is_installed 'brew'
    then
        # Fall back to looking for system LLVM on Linux when
        # Homebrew isn't installed.
        declare -A dict=(
            [find]="$(koopa::locate_find)"
            [sort]="$(koopa::locate_sort)"
            [tail]="$(koopa::locate_tail)"
        )
        x="$( \
            "${dict[find]}" '/usr/bin' -name 'llvm-config-*' \
            | "${dict[sort]}" \
            | "${dict[tail]}" -n 1 \
        )"
        [[ -n "$x" ]] && app="$x"
    fi
    koopa:::locate_app \
        --brew-opt='llvm' \
        --name="$app"
}

koopa::locate_ln() { # {{{1
    # """
    # Locate GNU ln.
    # @note Updated 2021-10-22.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app '/bin/ln'
}

koopa::locate_ls() { # {{{1
    # """
    # Locate GNU ls.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='ls'
}

koopa::locate_make() { # {{{1
    # """
    # Locate GNU make.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --gnubin \
        --name='make'
}

koopa::locate_man() { # {{{1
    # """
    # Locate GNU man.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='man-db' \
        --gnubin \
        --name='man'
}

koopa::locate_mkdir() { # {{{1
    # """
    # Locate GNU mkdir.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='mkdir'
}

koopa::locate_mktemp() { # {{{1
    # """
    # Locate GNU mktemp.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='mktemp'
}

koopa::locate_mv() { # {{{1
    # """
    # Locate GNU mv.
    # @note Updated 2021-10-22.
    #
    # macOS gmv currently has issues on NFS shares.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app '/bin/mv'
}

koopa::locate_nim() { # {{{1
    # """
    # Locate Nim.
    # @note Updated 2021-09-29.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'nim'
}

koopa::locate_node() { # {{{1
    # """
    # Locate node.
    # @note Updated 2021-09-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'node'
}

koopa::locate_npm() { # {{{1
    # """
    # Locate node package manager (npm).
    # @note Updated 2021-09-17.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='node' \
        --koopa-opt='node-packages' \
        --name='npm'
}

koopa::locate_openssl() { # {{{1
    # """
    # Locate openssl.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'openssl'
}

koopa::locate_parallel() { # {{{1
    # """
    # Locate GNU parallel.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'parallel'
}

koopa::locate_paste() { # {{{1
    # """
    # Locate GNU paste.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='paste'
}

koopa::locate_patch() { # {{{1
    # """
    # Locate GNU patch.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='gpatch' \
        --name='patch'
}

koopa::locate_pcregrep() { # {{{1
    # """
    # Locate pcregrep.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='pcre' \
        --name='pcregrep'
}

koopa::locate_perl() { # {{{1
    # """
    # Locate perl.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'perl'
}

koopa::locate_perlbrew() { # {{{1
    # """
    # Locate perlbrew.
    # @note Updated 2021-09-17.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'perlbrew'
}

koopa::locate_pkg_config() { # {{{1
    # """
    # Locate pkg-config.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'pkg-config'
}

koopa::locate_pkgutil() { # {{{1
    # """
    # Locate macOS pkgutil.
    # @note Updated 2021-10-26.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_macos
    koopa:::locate_app '/usr/sbin/pkgutil'
}

koopa::locate_python() { # {{{1
    # """
    # Locate Python.
    # @note Updated 2021-09-15.
    # """
    local app name version
    koopa::assert_has_no_args "$#"
    name='python'
    version="$(koopa::variable "$name")"
    version="$(koopa::major_version "$version")"
    app="${name}${version}"
    koopa:::locate_app \
        --macos-app="$(koopa::macos_python_prefix)/bin/${app}" \
        --name="$app"
}

koopa::locate_r() { # {{{1
    # """
    # Locate R.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --macos-app="$(koopa::macos_r_prefix)/bin/R" \
        --name='R'
}

koopa::locate_readlink() { # {{{1
    # """
    # Locate GNU readlink.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='readlink'
}

koopa::locate_realpath() { # {{{1
    # """
    # Locate GNU realpath.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='realpath'
}

koopa::locate_rename() { # {{{1
    # """
    # Locate Perl rename.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app "$(koopa::perl_packages_prefix)/bin/rename"
}

koopa::locate_rg() { # {{{1
    # """
    # Locate ripgrep.
    # @note Updated 2021-10-25.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='ripgrep' \
        --koopa-opt='ripgrep' \
        --name='rg'
}

koopa::locate_rm() { # {{{1
    # """
    # Locate GNU rm.
    # @note Updated 2021-10-22.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app '/bin/rm'
}

koopa::locate_rsync() { # {{{1
    # """
    # Locate rsync.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'rsync'
}

koopa::locate_ruby() { # {{{1
    # """
    # Locate ruby.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'ruby'
}

koopa::locate_rustc() { # {{{1
    # """
    # Locate Rust compiler.
    # @note Updated 2021-09-20.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='rust' \
        --koopa-opt='rust' \
        --name='rustc'
}

koopa::locate_sed() { # {{{1
    # """
    # Locate GNU sed.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='gnu-sed' \
        --gnubin \
        --name='sed'
}

koopa::locate_sort() { # {{{1
    # """
    # Locate GNU sort.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='sort'
}

koopa::locate_ssh() { # {{{1
    # """
    # Locate ssh.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='openssh' \
        --name='ssh'
}

koopa::locate_ssh_keygen() { # {{{1
    # """
    # Locate ssh.
    # @note Updated 2021-09-21.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='openssh' \
        --name='ssh-keygen'
}

koopa::locate_stat() { # {{{1
    # """
    # Locate GNU stat.
    # @note Updated 2021-10-22.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app '/usr/bin/stat'
}

koopa::locate_svn() { # {{{1
    # """
    # Locate svn.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'svn'
}

koopa::locate_tac() { # {{{1
    # """
    # Locate GNU tac.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='tac'
}

koopa::locate_tail() { # {{{1
    # """
    # Locate GNU tail.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='tail'
}

koopa::locate_tar() { # {{{1
    # """
    # Locate GNU tar.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='gnu-tar' \
        --gnubin \
        --name='tar'
}

koopa::locate_tee() { # {{{1
    # """
    # Locate GNU tee.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='tee'
}

koopa::locate_tr() { # {{{1
    # """
    # Locate GNU tr.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='tr'
}

koopa::locate_uncompress() { # {{{1
    # """
    # Locate GNU uncompress.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='gzip' \
        --gnubin \
        --name='uncompress'
}

koopa::locate_uname() { # {{{1
    # """
    # Locate GNU uname.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='uname'
}

koopa::locate_uniq() { # {{{1
    # """
    # Locate GNU uniq.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='uniq'
}

koopa::locate_unzip() { # {{{1
    # """
    # Locate unzip.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'unzip'
}

koopa::locate_wc() { # {{{1
    # """
    # Locate GNU wc.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='wc'
}

koopa::locate_wget() { # {{{1
    # """
    # Locate wget.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'wget'
}

koopa::locate_xargs() { # {{{1
    # """
    # Locate GNU xargs.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='findutils' \
        --gnubin \
        --name='xargs'
}

koopa::locate_yes() { # {{{1
    # """
    # Locate GNU yes.
    # @note Updated 2021-09-17.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='coreutils' \
        --gnubin \
        --name='yes'
}

koopa::locate_zcat() { # {{{1
    # """
    # Locate GNU zcat.
    # @note Updated 2021-09-21.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-opt='gzip' \
        --name='zcat'
}
