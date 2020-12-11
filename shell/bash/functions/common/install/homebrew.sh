#!/usr/bin/env bash

koopa::install_homebrew() { # {{{1
    # """
    # Install Homebrew.
    # @note Updated 2020-11-18.
    #
    # @seealso
    # - https://docs.brew.sh/Installation
    # - https://github.com/Homebrew/legacy-homebrew/issues/
    #       46779#issuecomment-162819088
    # - https://github.com/Linuxbrew/brew/issues/556
    #
    # macOS:
    # This script installs Homebrew to '/usr/local' so that you don't need sudo
    # when you run 'brew install'. It is a careful script; it can be run even if
    # you have stuff installed to '/usr/local' already. It tells you exactly
    # what it will do before it does it too. You have to confirm everything it
    # will do before it starts.
    #
    # Linux:
    # Creates a new linuxbrew user and installs to /home/linuxbrew/.linuxbrew.
    # """
    koopa::assert_has_no_args "$#"
    if koopa::is_installed brew
    then
        koopa::note 'Homebrew is already installed.'
        return 0
    fi
    koopa::assert_has_sudo
    koopa::assert_is_installed yes
    name_fancy='Homebrew'
    koopa::install_start "$name_fancy"
    if koopa::is_macos
    then
        koopa::assert_is_installed xcode-select
        koopa::h2 'Installing Xcode command line tools (CLT).'
        xcode-select --install &>/dev/null || true
    fi
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='install.sh'
        url="https://raw.githubusercontent.com/Homebrew/install/master/${file}"
        koopa::download "$url"
        chmod +x "$file"
        yes | "./${file}" || true
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

# FIXME ALLOW BREWFILE AS POSITIONAL ARGUMENT.
koopa::install_homebrew_bundle() { # {{{1
    # """
    # Install Homebrew packages using Bundle Brewfile.
    # @note Updated 2020-12-11.
    # """
    local brewfile default flags name_fancy remove_brews remove_taps x
    koopa::assert_has_sudo
    name_fancy='Homebrew Bundle'
    koopa::install_start "$name_fancy"
    koopa::assert_is_installed brew
    default=1
    brewfile="$(koopa::brewfile)"
    while (("$#"))
    do
        case "$1" in
            --brewfile=*)
                brewfile="${1#*=}"
                default=0
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_file "$brewfile"
    brewfile="$(realpath "$brewfile")"
    koopa::dl 'Brewfile' "$brewfile"
    brew analytics off
    if [[ "$default" -eq 1 ]]
    then
        # Remove any existing unwanted brews, if necessary.
        remove_brews=(
            'osgeo-gdal'
            'osgeo-hdf4'
            'osgeo-libgeotiff'
            'osgeo-libkml'
            'osgeo-libspatialite'
            'osgeo-netcdf'
            'osgeo-postgresql'
            'osgeo-proj'
        )
        if koopa::is_macos
        then
            remove_brews+=(
                'aspera-connect'  # renamed to ibm-aspera-connect
                'google-chrome-canary'
                'little-snitch'
                'safari-technology-preview'
                'zoomus'  # renamed to zoom
            )
        fi
        for x in "${remove_brews[@]}"
        do
            brew remove "$x" &>/dev/null || true
        done
        remove_taps=(
            'muesli/tap'
        )
        for x in "${remove_taps[@]}"
        do
            brew untap "$x" &>/dev/null || true
        done
    fi
    flags=(
        "--file=${brewfile}"
        '--debug'
        '--force'
        '--no-lock'
        '--no-upgrade'
        '--reinstall'
        '--verbose'
    )
    export HOMEBREW_CASK_OPTS='--no-quarantine'
    brew bundle install "${flags[@]}"
    koopa::brew_update
    return 0
}

koopa::install_homebrew_packages() { # {{{1
    koopa::install_homebrew_bundle "$@"
    return 0
}
