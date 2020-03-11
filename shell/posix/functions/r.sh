#!/bin/sh
# shellcheck disable=SC2039

_koopa_link_r_etc() {  # {{{1
    # """
    # Link R config files inside 'etc/'.
    # @note Updated 2020-03-11.
    #
    # Applies to 'Renviron.site' and 'Rprofile.site' files.
    # Note that on macOS, we don't want to copy the 'Makevars' file here.
    # """
    _koopa_is_installed R || return 1

    local r_home
    r_home="$(_koopa_r_home)"
    [ -d "$r_home" ] || return 1

    local koopa_prefix
    koopa_prefix="$(_koopa_prefix)"

    local os_id
    os_id="$(_koopa_os_id)"

    local r_etc_source
    r_etc_source="${koopa_prefix}/os/${os_id}/etc/R"
    [ -d "$r_etc_source" ] || return 1

    _koopa_ln "$r_etc_source" "${r_home}/etc"

    if _koopa_is_linux && [ -d '/etc/R' ]
    then
        _koopa_ln "$r_etc_source" '/etc/R'
    fi

    return 0
}

_koopa_link_r_site_library() {  # {{{1
    # """
    # Link R site library.
    # @note Updated 2020-03-03.
    # """
    _koopa_is_installed R || return 1

    local r_home
    r_home="$(_koopa_r_home)"
    [ -d "$r_home" ] || return 1

    local version
    version="$(_koopa_r_version)"

    local minor_version
    minor_version="$(_koopa_minor_version "$version")"

    local app_prefix
    app_prefix="$(_koopa_app_prefix)"

    local lib_source
    lib_source="${app_prefix}/r/${minor_version}/site-library"

    local lib_target
    lib_target="${r_home}/site-library"

    _koopa_mkdir "$lib_source"
    _koopa_ln "$lib_source" "$lib_target"

    # Debian R defaults to '/usr/local/lib/R/site-library' even though R_HOME
    # is '/usr/lib/R'. Ensure we link here also.
    if [[ -d "/usr/local/lib/R" ]]
    then
        _koopa_ln "$lib_source" "/usr/local/lib/R/site-library"
    fi

    return 0
}

_koopa_r_home() {  # {{{1
    # """
    # R home (prefix).
    # @note Updated 2020-03-03.
    # """
    _koopa_is_installed Rscript || return 1
    local home
    home="$(Rscript --vanilla -e 'cat(Sys.getenv("R_HOME"))')"
    [ -d "$home" ] || return 1
    _koopa_print "$home"
    return 0
}

_koopa_r_library_prefix() {  # {{{1
    # """
    # R default library prefix.
    # @note Updated 2020-02-10.
    # """
    _koopa_is_installed Rscript || return 1
    local prefix
    prefix="$(Rscript -e 'cat(.libPaths()[[1L]])')"
    [ -d "$prefix" ] || return 1
    _koopa_print "$prefix"
    return 0
}

_koopa_r_package_version() {  # {{{1
    # """
    # R package version.
    # @note Updated 2020-03-03.
    # """
    _koopa_is_installed Rscript || return 1
    local pkg
    pkg="${1:?}"
    _koopa_is_r_package_installed "$pkg" || return 1
    local x
    x="$(Rscript -e "cat(as.character(packageVersion(\"${pkg}\")), \"\n\")")"
    _koopa_print "$x"
    return 0
}

_koopa_r_system_library_prefix() {  # {{{1
    # """
    # R system library prefix.
    # @note Updated 2020-02-10.
    # """
    _koopa_is_installed Rscript || return 1
    local prefix
    prefix="$(Rscript --vanilla -e 'cat(tail(.libPaths(), n = 1L))')"
    [ -d "$prefix" ] || return 1
    _koopa_print "$prefix"
    return 0
}

_koopa_r_version() {  # {{{1
    # """
    # R version.
    # @note Updated 2020-03-01.
    # """
    _koopa_get_version R
    return 0
}

_koopa_update_r_config() {  # {{{1
    # """
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # @note Updated 2020-03-11.
    # """
    _koopa_is_installed R || return 1

    local r_home
    r_home="$(_koopa_r_home)"

    if _koopa_is_cellar R
    then
        _koopa_set_permissions --recursive "$r_home"
    else
        if [[ -d '/usr/lib/R' ]]
        then
            sudo chown -Rh 'root:root' '/usr/lib/R'
            sudo chmod -R 'g-w' '/usr/lib/R'
        fi

        if [[ -d /usr/share/R ]]
        then
            sudo chown -Rh 'root:root' '/usr/share/R'
            sudo chmod -R 'g-w' '/usr/share/R'
            # Need to ensure group write so package index gets updated.
            _koopa_set_permissions '/usr/share/R/doc/html/packages.html'
        fi

        # Ensure system package library is writable.
        _koopa_set_permissions --recursive "${r_home}/library"
    fi

    _koopa_link_r_etc
    _koopa_link_r_site_library

    # Update cellar links now that 'etc' has changed from directory to symlink.
    if _koopa_is_cellar R &&
        [[ -d '/usr/local/lib64/R/etc' ]] &&
        [[ ! -L '/usr/local/lib64/R/etc' ]]
    then
        _koopa_rm '/usr/local/lib64/R/etc'
        _koopa_link_cellar R
    fi

    _koopa_r_javareconf

    return 0
}

_koopa_update_r_config_macos() {  # {{{1
    # """
    # Update R config on macOS.
    # @note Updated 2020-03-03.
    #
    # Need to include Makevars to build packages from source.
    # """
    _koopa_is_installed R || return 1
    mkdir -pv "${HOME}/.R"
    ln -fnsv "/usr/local/koopa/os/macos/etc/R/Makevars" "${HOME}/.R/."
    return 0
}
