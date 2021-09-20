#!/usr/bin/env bash

koopa::macos_install_r_framework() { # {{{1
    # """
    # Install R framework.
    # @note Updated 2021-06-03.
    #
    # @section Intel:
    #
    # Important: this release uses Xcode 12.4 and GNU Fortran 8.2. If you wish
    # to compile R packages from sources, you may need to download GNU Fortran
    # 8.2 - see the tools directory.
    #
    # @section ARM:
    #
    # This release uses Xcode 12.4 and experimental GNU Fortran 11 arm64 fork.
    # If you wish to compile R packages from sources, you may need to download
    # GNU Fortran for arm64 from https://mac.R-project.org/libs-arm64. Any
    # external libraries and tools are expected to live in /opt/R/arm64 to not
    # conflict with Intel-based software and this build will not use /usr/local
    # to avoid such conflicts.
    #
    # @seealso
    # - https://cran.r-project.org/bin/macosx/
    # - https://mac.r-project.org/tools/
    # """
    local arch os_codename name name2 name_fancy os_codename prefix reinstall
    local tee tmp_dir url url_stem version
    koopa::assert_is_admin
    name='r'
    name2="$(koopa::capitalize "$name")"
    name_fancy="$name2"
    prefix='/Library/Frameworks/R.framework'
    reinstall=0
    tee="$(koopa::locate_tee)"
    version="$(koopa::variable "$name")"
    while (("$#"))
    do
        case "$1" in
            '--reinstall')
                reinstall=1
                shift 1
                ;;
            '--version='*)
                version="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    if [[ -d '/usr/local/Caskroom/r' ]]
    then
        koopa::alert_is_installed 'R Homebrew cask'
        return 0
    fi
    [[ "$reinstall" -eq 1 ]] && koopa::rm -S "$prefix"
    if [[ -d "$prefix" ]]
    then
        koopa::alert_is_installed "$name_fancy" "$prefix"
        return 0
    fi
    koopa::install_start "$name_fancy" "$version" "$prefix"
    url_stem='https://cran.r-project.org/bin/macosx'
    arch="$(koopa::arch)"
    os_codename="$(koopa::os_codename)"
    os_codename="$(koopa::kebab_case_simple "$os_codename")"
    case "$arch" in
        'aarch64')
            arch='arm64'
            file="R-${version}-${arch}.pkg"
            url="${url_stem}/${os_codename}-${arch}/base/${file}"
            ;;
        'x86_64')
            file="R-${version}.pkg"
            url="${url_stem}/base/${file}"
            ;;
        *)
            koopa::stop "Unsupported architecture: '${arch}'."
            ;;
    esac
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        koopa::download "$url"
        sudo installer -pkg "$file" -target /
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::assert_is_dir "$prefix"
    koopa::install_success "$name_fancy" "$prefix"
    koopa::alert_restart
    return 0
}

koopa::macos_uninstall_r_framework() { # {{{1
    # """
    # Uninstall R framework.
    # @note Updated 2021-06-03.
    # """
    local name_fancy
    name_fancy='R framework'
    koopa::uninstall_start "$name_fancy"
    koopa::rm -S \
        '/Applications/R.app' \
        '/Library/Frameworks/R.framework'
    koopa::delete_broken_symlinks '/usr/local/bin'
    koopa::uninstall_success "$name_fancy"
    return 0
}

