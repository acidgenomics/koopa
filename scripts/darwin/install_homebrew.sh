# Install Xcode CLT.
xcode-select --install

# Install Homebrew.
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Here's how to uninstall Homebrew (for reference).
# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"

# Update Homebrew.
brew update

# brew ====
brews=(flac    # priority
       lame    # priority
       tcl-tk  # priority
       bash
       bfg  # Java 1.7+ is required
       convmv
       coreutils
       curl
       exiftool
       ffmpeg
       findutils
       fish
       flac
       gcc
       gdal
       git
       git-lfs
       gsl
       hdf5
       hub
       imagemagick
       leiningen
       libav
       libgit2
       librsvg
       llvm  # full mainline: --with-toolchain (slow)
       mariadb-connector-c  # use instead of mysql
       mas
       node
       pandoc
       pandoc-citeproc
       pandoc-crossref
       protobuf
       "python --with-tcl-tk"
       rsync
       rbenv
       screen
       sshfs
       "sox --with-flac --with-lame"
       tesseract
       tmux
       trash
       tree
       vim
       wget
       wine
       youtube-dl
       zlib
       zsh)
for brew in ${brews[@]}; do
    brew install "$brew"
done

# brew cask ====
# dropbox has permission issues when installing using login from a non sudo account.
casks=(java     # priority
       osxfuse  # priority
       xquartz  # priority
       1password
       alfred
       atom
       authy
       basictex
       bbedit
       bibdesk
       carbon-copy-cloner
       coconutbattery
       coda
       docker
       emacs
       fiji
       firefox
       github
       google-chrome
       google-cloud-sdk
       google-drive-file-stream
       gpg-suite
       hazel
       igv
       iterm2
       keka
       libreoffice
       little-snitch
       omnidisksweeper
       onyx
       r-app
       rstudio
       skype
       slack
       spillo
       sublime-text
       superduper
       torbrowser
       tower
       transmit
       tunnelblick
       vlc
       xld)
for cask in ${casks[@]}; do
    brew cask install --force "$cask"
done
