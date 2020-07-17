#!/usr/bin/env bash

koopa::brew_cask_outdated() { # {{{
    # """
    # List outdated Homebrew casks.
    # @note Updated 2020-07-03.
    #
    # Need help with capturing output:
    # - https://stackoverflow.com/questions/58344963/
    # - https://unix.stackexchange.com/questions/253101/
    #
    # @seealso
    # - brew leaves
    # - brew deps --installed --tree
    # - brew list --versions
    # - brew info
    # """
    local tmp_file x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed brew
    tmp_file="$(koopa::tmp_file)"
    script -q "$tmp_file" brew cask outdated --greedy >/dev/null
    x="$(grep -v "(latest)" "$tmp_file")"
    [[ -n "$x" ]] && return 0
    koopa::print "$x"
    return 0
}

koopa::brew_cask_quarantine_fix() {
    sudo xattr -r -d com.apple.quarantine /Applications/*.app
    return 0
}

koopa::brew_outdated() { # {{{
    # """
    # Listed outdated Homebrew brews and casks, in a single call.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa::h1 "Checking for outdated Homebrew formula."
    brew update &>/dev/null
    koopa::h2 "Brews"
    brew outdated
    koopa::h2 "Casks"
    koopa::brew_cask_outdated
    return 0
}

koopa::brew_update() { # {{{1
    # """
    # Updated outdated Homebrew brews and casks.
    # @note Updated 2020-07-01.
    #
    # Alternative approaches:
    # > brew list \
    # >     | xargs brew reinstall --force-bottle --cleanup \
    # >     || true
    # > brew cask outdated --greedy \
    # >     | xargs brew cask reinstall \
    # >     || true
    #
    # @seealso
    # Refer to useful discussion regarding '--greedy' flag.
    # https://discourse.brew.sh/t/brew-cask-outdated-greedy/3391
    # """
    local casks name_fancy
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed brew
    name_fancy="Homebrew"
    koopa::update_start "$name_fancy"
    brew analytics off
    brew update >/dev/null
    koopa::h2 "Updating brews."
    brew upgrade --force-bottle || true
    koopa::h2 "Updating casks."
    casks="$(koopa::brew_cask_outdated)"
    if [[ -n "$casks" ]]
    then
        koopa::info "${#casks[@]} outdated casks detected."
        koopa::print "${casks[@]}"
        koopa::print "${casks[@]}" \
            | cut -d " " -f 1 \
            | xargs brew cask reinstall \
            || true
    fi
    koopa::h2 "Running cleanup."
    brew cleanup -s || true
    rm -fr "$(brew --cache)"
    koopa::update_r_config
    koopa::update_success "$name_fancy"
    return 0
}

koopa::macos_install_homebrew() {
    # """
    # Install Homebrew.
    # @note Updated 2020-07-17.
    #
    # @seealso
    # https://docs.brew.sh/Installation
    #
    # This script installs Homebrew to '/usr/local' so that you don’t need sudo
    # when you run 'brew install'. It is a careful script; it can be run even if
    # you have stuff installed to '/usr/local' already. It tells you exactly
    # what it will do before it does it too. You have to confirm everything it
    # will do before it starts.
    #
    # Alternative install, supporting custom prefix (e.g. /usr/local/homebrew):
    # > mkdir homebrew && \
    # >     curl -L https://github.com/Homebrew/brew/tarball/master \
    # >     | tar xz --strip 1 -C homebrew
    # """
    koopa::assert_has_no_args "$#"
    koopa::exit_if_installed brew
    koopa::assert_is_installed xcode-select
    name_fancy='Homebrew'
    koopa::install_start "$name_fancy"
    koopa::h2 'Installing Xcode command line tools (CLT).'
    xcode-select --install &>/dev/null || true
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='install.sh'
        url="https://raw.githubusercontent.com/Homebrew/install/master/${file}"
        koopa::download "$url"
        chmod +x "$file"
        "./${file}"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::macos_install_homebrew_little_snitch() {
    # """
    # Install Little Snitch via Homebrew Cask.
    # @note Updated 2020-07-17.
    # """
    local dmg_file version
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed hdiutil open
    version="$(koopa::extract_version "$(brew cask info little-snitch)")"
    dmg_file="$(koopa::homebrew_prefix)/Caskroom/little-snitch/\
${version}/LittleSnitch-${version}.dmg"
    koopa::assert_is_file "$dmg_file"
    hdiutil attach "$dmg_file" &>/dev/null
    open "/Volumes/Little Snitch ${version}/Little Snitch Installer.app"
    return 0
}

koopa::macos_install_homebrew_recipes() { # {{{1
    # """
    # Check taps with `brew tap`.
    #
    # Potentially useful binaries:
    # https://github.com/mathiasbynens/dotfiles/blob/main/brew.sh
    #
    # XQuartz:
    # Install XQuartz 2.7.9 manually instead of using 'xquartz' cask.
    #
    # Little Snitch:
    # 'little-snitch' cask currently requires manual follow-up installation:
    # /usr/local/Caskroom/little-snitch/*/LittleSnitch-*.dmg
    #
    # LLVM:
    # LLVM takes up 4 GB of disk space but is required for some Python packages.
    # In particular, if we want to install umap-learn, this is now required.
    #
    # PROJ/GDAL:
    # Consider using 'osgeo-gdal' instead of regular 'gdal' brew. This one gets
    # updated more regularly. However, I've found that the newer version can
    # cause some R packages to fail to build from source.
    #
    # Rust:
    # Just use the 'install-rust' script instead of Homebrew 'rustup-init'. I
    # hit some permissions issues with the 'rustup' cellar symlink installed at
    # '/usr/local/bin/rustup' that doesn't occur when running the official
    # script. And be sure not to install 'rust' alongside 'rustup-init'.
    # """
    local brew brews cask casks installed_brews installed_casks name \
        name_fancy tap taps untap untaps
    koopa::assert_has_no_args "$#"
    name_fancy='Homebrew recipes'
    koopa::install_start "$name_fancy"
    koopa::assert_is_installed brew
    export HOMEBREW_FORCE_BOTTLE=1

    # Casks {{{2
    # --------------------------------------------------------------------------

    # 'foobar2000' cask was removed due to url protection.
    # 'macvim' cask overwrites 'vim' binary, so install manually instead.
    # 'skype-for-business' is potentially useful but starts up at login.

    # Requires authentication in 'Security & Privacy':
    # - box-drive
    # - virtualbox

    # Casks that don't auto-update correctly:
    # - bibdesk
    # - firefox
    # - tunnelblick
    # - visual-studio-code
    # - iterm

    koopa::h2 'Installing casks.'
    installed_casks="$(brew cask list)"
    casks=(
        # Priority {{{3
        # ----------------------------------------------------------------------
        'xquartz'
        # Alphabetical {{{3
        # ----------------------------------------------------------------------
        # fiji  # latest
        # onyx
        # oracle-jdk
        # wine-stable
        '1password'
        'adobe-acrobat-reader'
        'adoptopenjdk'  # igv
        'alacritty'
        'alfred'
        'aspera-connect'
        'authy'
        'basictex'
        'bbedit'
        'bibdesk'
        'calibre'
        'carbon-copy-cloner'
        'coconutbattery'
        'coda'
        'darktable'
        'deluge'
        'docker'
        'emacs'
        'firefox'
        'github'
        'google-chrome'
        'google-chrome-canary'
        'google-cloud-sdk'  # latest
        'google-drive-file-stream'  # latest
        'gpg-suite'
        'hazel'
        'igv'
        'iterm2'
        'java'
        'julia'
        'keka'
        'kid3'
        'kitty'
        'libreoffice'
        'little-snitch'
        'makemkv'
        'museeks'
        'netnewswire'
        'omnidisksweeper'
        'osxfuse'
        'pacifist'
        'photosweeper-x'
        'powershell'
        'pycharm-ce'
        'r'
        'rstudio'
        'safari-technology-preview'
        'scrivener'
        'skype'
        'spillo'
        'sublime-text'
        'superduper'
        'swinsian'
        'textmate'
        'tiny-player'
        'tor-browser'
        'tower'
        'transmit'
        'tunnelblick'
        'visual-studio-code'
        'vlc'
        'xld'
        'zoomus'
    )
    for cask in "${casks[@]}"
    do
        name="$(basename "$cask")"
        if koopa::str_match_regex "$installed_casks" "^${name}$"
        then
            koopa::note "\"${cask}\" is already installed."
            continue
        fi
        koopa::info "Installing \"${cask}\."
        brew cask install --force --no-quarantine "$cask"
    done

    # Brews {{{2
    # --------------------------------------------------------------------------

    # Use rustup / cargo to manage these Rust packages instead:
    # - broot
    # - exa
    # - fd
    # - ripgrep
    # - xsv

    koopa::h2 'Installing brews.'
    installed_brews="$(brew list)"

    # Linked brews (default) {{{3
    # --------------------------------------------------------------------------

    brews=(
        # Priority {{{4
        # ----------------------------------------------------------------------
        'python@3.8'
        'bash'
        'fish'
        'ksh'
        'tcsh'
        'zsh'
        'openblas'
        'tcl-tk'
        'flac'
        'lame'
        # Alphabetical {{{4
        # ----------------------------------------------------------------------
        # moreutils  # conflicts with parallel and ts
        # pyenv
        # rbenv (or use rvm?)
        # ruby-build
        'ack'
        'autoconf'
        'autojump'
        'automake'
        'awscli'
        'azure-cli'
        'bash-completion'
        'bfg'
        'binutils'
        'ccache'
        'checkbashisms'
        'circleci'
        'cmake'
        'convmv'
        'coreutils'
        'curl'
        'dash'
        'exiftool'
        'ffmpeg'
        'findutils'
        'fzf'
        'gawk'
        'gcc'
        'gdal'
        'git'
        'git-lfs'
        'gnu-sed'
        'gnu-tar'
        'gnu-time'
        'gnu-units'
        'gnu-which'
        'go'
        'gpatch'
        'grep'
        'groff'
        'gsl'
        'hdf5'
        'htop'
        'httpd'  # php
        'hub'
        'igraph'
        'imagemagick'
        'jq'
        'ksh'
        'leiningen'
        'lesspipe'
        'libav'
        'libgeotiff'  # gdal/proj
        'libgit2'
        'libiconv'
        'libomp'
        'libressl'
        'librsvg'
        'libspatialite'  # gdal/proj
        'libssh2'
        'libtool'
        'libxml2'
        'libxslt'
        'llvm'
        'lua'
        'luarocks'
        'make'
        'man-db'
        'mariadb-connector-c'
        'mas'
        'neofetch'
        'neovim'
        'netcdf'  # gdal/proj
        'nmap'
        'node'
        'open-mpi'
        'openblas'
        'openssh'
        'pandoc'
        'pandoc-citeproc'
        'pandoc-crossref'
        'parallel'
        'pass'
        'php'
        'pkg-config'
        'podofo'
        'proj'
        'protobuf'
        'rename'
        'rsync'
        'ruby'
        'screen'
        'shellcheck'
        'shellharden'
        'shunit2'
        'sox'
        'sqlite'
        'sshfs'
        'subversion'
        'tesseract'
        'texinfo'
        'the_silver_searcher'  # ag
        'tmux'
        'trash'
        'tree'
        'udunits'
        'v8'
        'vim'
        'wget'
        'youtube-dl'
        'zlib'
    )
    for brew in "${brews[@]}"
    do
        if koopa::str_match_regex "$installed_brews" "^${brew}$"
        then
            koopa::note "\"${brew}\" is already installed."
            continue
        fi
        koopa::info "Installing \"${brew}\."
        brew install "$brew"
        brew link "$brew" &>/dev/null || true
    done

    # Cellar (keg)-only brews {{{3
    # --------------------------------------------------------------------------

    # > keg_only_brews=(
    # >     'python'
    # > )
    # > for brew in "${keg_only_brews[@]}"
    # > do
    # >     if koopa::str_match_regex "$installed_brews" "^${brew}$"
    # >     then
    # >         koopa::note "\"${brew}\" is already installed."
    # >         continue
    # >     fi
    # >     koopa::info "Installing \"${brew}\"."
    # >     brew install "$brew"
    # >     brew unlink "$brew" >/dev/null || true
    # > done

    # Externally tapped brews {{{3
    # --------------------------------------------------------------------------

    # Brews from 'osgeo/osgeo4mac' tap are newer but can break R compilation.
    # This is needed currently to install R rgdal, sf packages from source.
    taps=(
        'mongodb/brew'
        'vitorgalvao/tiny-scripts'
    )
    for tap in "${taps[@]}"
    do
        brew tap "$tap"
    done
    untaps=(
        'osgeo/osgeo4mac'
    )
    for untap in "${untaps[@]}"
    do
        brew untap "$untap" 2>/dev/null || true
    done
    external_brews=(
        # osgeo/osgeo4mac/osgeo-gdal
        # osgeo/osgeo4mac/osgeo-proj
        'mongodb/brew/mongodb-community'
        'vitorgalvao/tiny-scripts/cask-repair'
    )
    for brew in "${external_brews[@]}"
    do
        name="$(basename "$brew")"
        if koopa::str_match_regex "$installed_brews" "^${name}$"
        then
            koopa::note "\"${brew}\" is already installed."
            continue
        fi
        koopa::info "Installing \"${brew}\."
        brew install "$brew"
        brew link "$brew" &>/dev/null || true
    done

    koopa::install_success "$name_fancy"
    return 0
}

koopa::macos_update_homebrew() {
    # """
    # Update Homebrew.
    # @note Updated 2020-07-17.
    # """
    koopa::exit_if_not_installed brew
    koopa::brew_update "$@"
    return 0
}

