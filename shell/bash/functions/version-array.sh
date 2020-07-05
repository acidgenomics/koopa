#!/usr/bin/env bash

koopa::extract_version() { # {{{1
    # """
    # Extract version number.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_args "$#"
    local arg pattern x
    pattern="$(koopa::version_pattern)"
    for arg in "$@"
    do
        x="$( \
            koopa::print "$arg" \
                | grep -Eo "$pattern" \
                | head -n 1 \
        )"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::get_homebrew_cask_version() { # {{{1
    # """
    # Get Homebrew Cask version.
    # @note Updated 2020-07-05.
    #
    # @examples koopa::get_homebrew_cask_version gpg-suite
    # # 2019.2
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed brew
    local cask x
    for cask in "$@"
    do
        x="$(brew cask info "$cask")"
        x="$(koopa::extract_version "$x")"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::get_macos_app_version() { # {{{1
    # """
    # Extract the version of a macOS application.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_macos
    koopa::assert_is_installed plutil
    local app plist x
    for app in "$@"
    do
        plist="/Applications/${app}.app/Contents/Info.plist"
        if [[ ! -f "$plist" ]]
        then
            koopa::stop "'${app}' is not installed."
        fi
        x="$( \
            plutil -p "$plist" \
                | grep 'CFBundleShortVersionString' \
                | awk -F ' => ' '{print $2}' \
                | tr -d '\"' \
        )"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::get_version() { # {{{1
    # """
    # Get the version of an installed program.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_args "$#"
    local cmd fun x
    for cmd in "$@"
    do
        fun="koopa::$(koopa::snake_case "$cmd")_version"
        if koopa::is_function "$fun"
        then
            x="$("$fun")"
        else
            x="$(koopa::return_version "$cmd")"
        fi
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::major_version() { # {{{1
    # """
    # Program 'MAJOR' version.
    # @note Updated 2020-07-04.
    #
    # This function captures 'MAJOR' only, removing 'MINOR.PATCH', etc.
    # """
    koopa::assert_has_args "$#"
    local version x
    for version in "$@"
    do
        x="$(koopa::print "$version" | cut -d '.' -f 1)"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::major_minor_version() { # {{{1
    # """
    # Program 'MAJOR.MINOR' version.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args "$#"
    local version x
    for version in "$@"
    do
        x="$(koopa::print "$version" | cut -d '.' -f 1-2)"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::major_minor_patch_version() { # {{{1
    # """
    # Program 'MAJOR.MINOR.PATCH' version.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args "$#"
    local version x
    for version in "$@"
    do
        x="$(koopa::print "$version" | cut -d '.' -f 1-3)"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

# FIXME PARAMETERIZE.
# FIXME USE R HERE INSTEAD OF RSCRIPT.
# FIXME DONT USE RSCRIPT IN FUNCTIONS...
# FIXME SAFE TO MOVE TO BASH, IF NECESSARY.
koopa::r_package_version() { # {{{1
    # """
    # R package version.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_args "$#"
    local pkg r rscript x
    r='R'

    rscript"${r}script"
    koopa::assert_is_installed "$r" "$rscript"

    # FIXME REWORK THIS: FLAG SUPPORT?.
    koopa::assert_is_r_package_installed "$pkg" "$rscript"

    for pkg in "$@"
    do
        x="$( \
            "$rscript" \
            -e "cat(as.character(packageVersion(\"${pkg}\")), \"\n\")" \
        )"
        [[ -n "$x" ]] || return 1
        koopa::print "$x"
    done
    return 0
}

koopa::sanitize_version() { # {{{1
    # """
    # Sanitize version.
    # @note Updated 2020-07-05.
    # """
    koopa::assert_has_args "$#"
    local pattern x
    pattern='[.0-9]+'
    for x in "$@"
    do
        koopa::str_match_regex "$x" "$pattern" || return 1
        x="$(koopa::print "$x" | grep -Eo "$pattern")"
        koopa::print "$x"
    done
    return 0
}
