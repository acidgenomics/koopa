#!/usr/bin/env bash

# Last updated 2022-04-11.

# Recipes that we need to install:
# - libtasn1
# - lapack
# - openblas

# First configure the shell to load koopa.
koopa install dotfiles
# We need to install AWS CLI to push builds to S3 bucket.
koopa install aws-cli --push
koopa install pkg-config --push --reinstall
koopa install tar --push --reinstall
koopa install xz --push --reinstall
koopa install gettext --push --reinstall
# This is currently problematic on macOS but works on Ubuntu.
koopa install attr --push --reinstall
koopa install coreutils --push --reinstall
koopa install findutils --push --reinstall
koopa install autoconf --push --reinstall
koopa install automake --push --reinstall
koopa install zlib --push --reinstall
# NOTE Consider skipping this on Linux.
koopa install openssl --push --reinstall
koopa install make --push --reinstall
koopa install cmake --push --reinstall
koopa install grep --push --reinstall
koopa install curl --push --reinstall
# Ensure we switch back to system shell before installing.
koopa install bash --push --reinstall
koopa install zsh --push --reinstall

# Ubuntu is here:
koopa install python --push --reinstall
koopa install git --push --reinstall
koopa install rsync --push --reinstall
koopa install ncurses --push --reinstall

libevent
tmux
libtool
apr
apr-util
pcre2
fish
perl
gawk
sqlite
geos
proj
gdal


# Ubuntu machine:
sed
rust
rust-packages
fltk
gnupg
gmp
go
groff
haskell-stack
hdf5
icu4c
imagemagick
jpeg
julia
lesspipe
libidn
libtiff
libxml2


# MacBook:
nettle
gnutls (libtasn1)
libzip (maybe require gnutls here)

lua
luarocks
meson
neofetch
neovim
nim
ninja
node
rsync
ruby
scons
serf
subversion
tree
udunits
vim
wget
zlib
zstd
cpufetch

nim-packages
node-packages
perl-packages

koopa install chemacs --push --reinstall

# Don't push these:
conda
anaconda
julia-packages
python-packages
r-packages
ruby-packages

# > openssh (requires ldns)
# > gcc
